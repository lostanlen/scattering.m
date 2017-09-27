% Define parameters.
Q1 = 24;
T = 512;
modulations = 'none';
wavelets = 'morlet';
N = 131072;


% Load waveform.
audio_names = {'taslp18_dog-bark', 'taslp18_flute'};


% Construct wavelet filter bank for visualization.
vis_archs = taslp18_setup_visualization(Q1, N);


% Construct wavelet filter banks for reconstruction.
rec_archs = taslp18_setup_reconstruction(Q1, T, modulations, wavelets, N);


for audio_name_id = 1:length(audio_names)
    % Load waveform.
    audio_name = audio_names{audio_name_id};
    audio_path = [audio_name, '.wav'];
    [target_waveform, sample_rate] = taslp18_load(audio_path, N);

    % Compute scattering transform.
    target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
    target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
    target_U1 = Y_to_U(target_Y1{end}, vis_archs{1}.nonlinearity);

    % Display original scalogram.
    target_scalogram = display_scalogram(target_U1);
    imagesc(log1p(target_scalogram));
    colormap rev_magma;
    axis off;
    drawnow();
    export_fig([audio_name, '_original.png']);

    % Reconstruct.
    while (iteration <= opts.nIterations) && (~opts.is_spectrogram_displayed || is_display_active)
        %% Signal update
        iterations{1+iteration} = update_reconstruction( ...
            previous_signal, ...
            delta_signal, ...
            signal_update, ...
            learning_rate, ...
            opts);

        %% Scattering propagation
        S = cell(1, nLayers);
        U = cell(1,nLayers);
        Y = cell(1,nLayers);
        U{1+0} = initialize_variables_auto(size(y));
        U{1+0}.data = iterations{1+iteration};
        for layer = 1:nLayers
            arch = rec_archs{layer};
            previous_layer = layer - 1;
            if isfield(arch, 'banks')
                Y{layer} = U_to_Y(U{1+previous_layer}, arch.banks);
            else
                Y{layer} = U(1+previous_layer);
            end
            if isfield(arch, 'nonlinearity')
                U{1+layer} = Y_to_U(Y{layer}{end}, arch.nonlinearity);
            end
            if isfield(arch, 'invariants')
                S{1+previous_layer} = Y_to_S(Y{layer}, arch);
            end
        end

        %% Measurement of distance to target in the scattering domain
        delta_S = sc_substract(target_S, S);

        %% If loss has increased, step retraction and bold driver "brake"
        [loss, layer_absolute_distances] = sc_norm(delta_S);
        if opts.adapt_learning_rate && (loss > previous_loss)
            learning_rate = ...
                opts.bold_driver_brake * learning_rate;
            signal_update = ...
                opts.bold_driver_brake * signal_update;
            if opts.is_verbose
                disp(['Learning rate = ', num2str(learning_rate)]);
            end
            failure_counter = failure_counter + 1;
            if failure_counter > 3
                learning_rate = opts.initial_learning_rate;
            else
                continue
            end
        end

        %% If loss has decreased, step confirmation and bold driver "acceleration"
        iteration = iteration + 1;
        failure_counter = 0;
        relative_loss_chart(iteration) = 100 * loss / target_norm;
        relative_layer_loss_chart(:, iteration) = ...
            100 * layer_absolute_distances / target_norm;
        previous_signal = iterations{iteration};
        previous_loss = loss;
        signal_update = ...
            opts.momentum * signal_update + ...
            learning_rate * delta_signal;
        learning_rate = ...
            opts.bold_driver_accelerator * ...
            learning_rate;

        %% Backpropagation
        delta_signal = sc_backpropagate(delta_S, U, Y, archs);

        %% Pretty-printing of scattering distances and loss function
        if opts.is_verbose
            pretty_iteration = sprintf(sprintf_format, iteration);
            layer_distances = ...
                100 * layer_absolute_distances ./ layer_target_norms;
            pretty_distances = num2str(layer_distances(2:end), '%8.2f%%');
            pretty_loss = sprintf('%.2f%%', relative_loss_chart(iteration));
            iteration_string = ['it = ', pretty_iteration, '  ;  '];
            distances_string = ...
                ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
            loss_string = ['Loss = ', pretty_loss];
            disp([iteration_string, distances_string, loss_string]);
            disp(['Learning rate = ', num2str(learning_rate)]);
            toc();
            tic();
        end
    end
end

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
