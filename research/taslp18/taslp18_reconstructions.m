% Define parameters.
Q1 = 8;
wavelet_str = 'morlet';
N = 131072;
modulations_strs = {'none', 'time', 'time-frequency'};
Ts = [2^11, 2^13, 2^15, 2^17];


% Load waveform.
audio_names = {'taslp18_dog-bark', 'taslp18_flute'};


% Construct wavelet filter bank for visualization.
vis_archs = taslp18_setup_visualization(24, N);


for audio_name_id = 1:length(audio_names)
    % Load waveform.
    audio_name = audio_names{audio_name_id};
    audio_path = [audio_name, '.wav'];
    [target_waveform, sample_rate] = taslp18_load(audio_path, N);

    % Compute scalogram.
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

    % Loop on modulations.
    for modulations_id = 1:length(modulations_strs)
        modulations_str = modulations_strs{modulations_id};

        for T_id = 1:length(Ts)
            % Construct wavelet filter banks for reconstruction.
            T = Ts(T_id);
            rec_archs = taslp18_setup_reconstruction( ...
                Q1, T, modulations_str, wavelet_str, N);

            % Reconstruct.
            iteration = 1;
            failure_counter = 0;

            %% Default options.
            opts = struct();
            opts.nIterations = 100;
            opts = fill_reconstruction_opt(opts);
            max_nDigits = 1 + floor(log10(opts.nIterations));
            sprintf_format = ['%0.', num2str(max_nDigits), 'd'];

            %% Forward propagation of target signal
            target_S = eca_target(target_waveform, rec_archs);
            [target_norm, layer_target_norms] = sc_norm(target_S);
            nLayers = length(rec_archs);

            %% Initialization
            [init, previous_loss, delta_signal] = ...
                eca_init(target_waveform, target_S, rec_archs, opts);
            iterations = cell(1, opts.nIterations);
            iterations{1+0} = init;
            previous_signal = iterations{1+0};
            relative_loss_chart = zeros(1, opts.nIterations);
            relative_layer_loss_chart = zeros(nLayers, opts.nIterations);
            signal_update = zeros(size(iterations{1+0}));
            learning_rate = opts.initial_learning_rate;
            tic();

            while (iteration <= opts.nIterations)
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
                U{1+0} = initialize_variables_auto(size(target_waveform));
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
                    opts.momentum * signal_update + learning_rate * delta_signal;
                learning_rate = ...
                    opts.bold_driver_accelerator * learning_rate;

                %% Backpropagation
                delta_signal = sc_backpropagate(delta_S, U, Y, rec_archs);

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

            % Display reconstructed scalogram.
            rec_U0 = initialize_U(iterations{end}, vis_archs{1}.banks{1});
            rec_Y1 = U_to_Y(rec_U0, vis_archs{1}.banks);
            rec_U1 = Y_to_U(rec_Y1{end}, vis_archs{1}.nonlinearity);
            rec_scalogram = display_scalogram(rec_U1);
            imagesc(log1p(rec_scalogram));
            colormap rev_magma;
            axis off;
            drawnow();
            export_fig([ ...
                audio_name, ...
                 '_Q=', num2str(Q1, '%0.2d'), ...
                 '_J=', num2str(log2(T), '%0.2d'), ...
                 '_sc=', modulations_str, ...
                 '_wvlt=', wavelet_str, ...
                 '.png']);

            % Export
            audiowrite([ ...
                audio_name, ...
                 '_Q=', num2str(Q1, '%0.2d'), ...
                 '_J=', num2str(log2(T), '%0.2d'), ...
                 '_sc=', modulations_str, ...
                 '_wvlt=', wavelet_str, ...
                 '.wav'], ...
                 iterations{end}, ...
                 sample_rate, ...
                'BitsPerSample', bit_depth);
        end
    end
end
