% Script arguments:
% * J
% * audio_name_str
% * modulations_str
% * wavelet_str

% Define parameters.
Q1 = 8;
N = 131072;
T = 2^J;


% Construct wavelet filter bank for visualization.
vis_archs = taslp18_setup_visualization(24, N);


% Load waveform.
audio_path = ['media/', audio_name_str, '.wav'];
[target_waveform, sample_rate] = taslp18_load(audio_path, N / 2);


% Compute scalogram.
target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
target_U1 = Y_to_U(target_Y1{end}, vis_archs{1}.nonlinearity);


% Append waveform with itself.
target_waveform = cat(1, target_waveform, target_waveform);


% Display original scalogram.
%target_scalogram = display_scalogram(target_U1);
%imagesc(log1p(target_scalogram));
%colormap rev_magma;
%axis off;
%drawnow();
%export_fig([audio_name_str, '_original.png']);


% Construct wavelet filter banks for reconstruction.
rec_archs = taslp18_setup_reconstruction( ...
    Q1, T, modulations_str, wavelet_str, N);


% Reconstruct.
iteration = 1;
failure_counter = 0;
display_period = 10;


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
S1_energy = sqrt(sum(target_S{1+1}.data.^2, 1));
resolutions = ...
    [target_S{1+1}.variable_tree.time{1}.gamma{1}.leaf.metas.resolution];
mother_xi = rec_archs{1+0}.banks{1}.spec.mother_xi;
frequencies = transpose(cat(2, round(N * mother_xi * resolutions), 0.0));
S1_energy = transpose(cat(2, S1_energy, ...
    zeros(1, 1 + length(resolutions) - length(S1_energy))));
frequencies = cat(1, N - frequencies(end:-1:1), frequencies);
S1_energy = cat(1, S1_energy(end:-1:1), S1_energy);
colored_noise_abs_ft = transpose(interp1(frequencies, S1_energy, 0:(N-1)));
phasors = exp(2i * pi * rand(N, 1));
colored_noise_ft = colored_noise_abs_ft .* phasors;
colored_noise = real(ifft(colored_noise_ft));
colored_noise = colored_noise * norm(target_waveform) / norm(colored_noise);
opts.initial_signal = colored_noise;
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


% Create subfolder.
subfolder_str = [ ...
    audio_name_str, ...
    '_Q=', num2str(Q1, '%0.2d'), ...
    '_J=', num2str(log2(T), '%0.2d'), ...
    '_sc=', modulations_str, ...
    '_wvlt=', wavelet_str];
if ~exist(['media/', subfolder_str])
    mkdir(['media/', subfolder_str]);
end


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

    if iteration % display_period == 0
        % Display reconstructed scalogram.
        rec_U0 = initialize_U( ...
            iterations{iteration}(1:(end/2)), vis_archs{1}.banks{1});
        rec_Y1 = U_to_Y(rec_U0, vis_archs{1}.banks);
        rec_U1 = Y_to_U(rec_Y1{end}, vis_archs{1}.nonlinearity);
        rec_scalogram = display_scalogram(rec_U1);
        imagesc(log1p(rec_scalogram));
        colormap rev_magma;
        axis off;
        drawnow();
        export_fig([ ...
            'media/', subfolder_str, '/', ...
            audio_name_str, ...
             '_Q=', num2str(Q1, '%0.2d'), ...
             '_J=', num2str(log2(T), '%0.2d'), ...
             '_sc=', modulations_str, ...
             '_wvlt=', wavelet_str, ...
             '_it=', num2str(iteration, '%0.3d'), ...
             '.png']);


        % Export
        audiowrite([ ...
            'media/', subfolder_str, '/', ...
            audio_name_str, ...
             '_Q=', num2str(Q1, '%0.2d'), ...
             '_J=', num2str(log2(T), '%0.2d'), ...
             '_sc=', modulations_str, ...
             '_wvlt=', wavelet_str, ...
             '_it=', num2str(iteration, '%0.3d'), ...
             '.wav'], ...
             iterations{iteration}(1:(end/2)), ...
             sample_rate, ...
            'BitsPerSample', 16);
    end

end
