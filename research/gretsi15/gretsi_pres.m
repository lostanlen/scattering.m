file_path = 'Vc-scale-chr-asc.wav';
[full_waveform, sample_rate] = audioread_compat(file_path);

%%
N = 2^16;
target_signal = full_waveform(1:N);

%%
T = N/4;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 128];

opts{1}.nonlinearity.name = 'uniform_log';
opts{1}.nonlinearity.denominator = 1e2;

opts{2}.time.T = T;
opts{2}.time.max_scale = Inf;
opts{2}.time.handle = @morlet_1d;
opts{2}.time.sibling_mask_factor = 2;
opts{2}.time.max_Q = 1;
opts{2}.time.has_duals = true;
opts{2}.time.U_log2_oversampling = 1;

opts{2}.gamma.T = 4 * opts{1}.time.nFilters_per_octave;
opts{2}.gamma.handle = @morlet_1d;
opts{2}.gamma.nFilters_per_octave = 2;
opts{2}.gamma.max_Q = 1;
opts{2}.gamma.cutoff_in_dB = 1.0;
opts{2}.gamma.has_duals = true;
opts{2}.gamma.U_log2_oversampling = 2;
opts{2}.gamma.S_log2_oversampling = 2;

opts{2}.j.invariance = 'bypassed';
opts{2}.j.T = 4;
opts{2}.j.phi_bw_multiplier = 1;
opts{2}.j.has_duals = true;
opts{2}.j.handle = @morlet_1d;

reconstruction_opt.verbosity_period = 1;
reconstruction_opt.signal_display_period = 1;
reconstruction_opt.learning_rate = 0.1;
reconstruction_opt.momentum = 0.9;
reconstruction_opt.bold_driver_accelerator = 1.1;
reconstruction_opt.bold_driver_brake = 0.5;

%% Architecture setup
archs = sc_setup(opts);

%% Forward propagation
nLayers = length(archs);
target_S = cell(1,1+nLayers);
target_U = cell(1,1+nLayers);
target_Y = cell(1,1+nLayers);
target_U{1+0} = initialize_variables_auto(size(target_signal));
target_U{1+0}.data = target_signal;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    target_Y{layer} = U_to_Y(target_U{1+previous_layer},arch);
    % Apply non-linearity to last sub-layer Y to get layer U
    target_U{1+layer} = Y_to_U(target_Y{layer}{end},arch);
    % Blur/pool first sub-layer Y to get layer S
    target_S{1+previous_layer} = Y_to_S(target_Y{layer},arch);
end
target_Y{1+nLayers}{1+0} = initialize_Y(target_U{1+nLayers},arch.banks);
target_S{1+nLayers} = Y_to_S(target_Y{1+nLayers},arch);

%% Initialization
signal = generate_pink_noise(N);
signal = signal - mean(signal);
signal = signal * norm(target_signal)/norm(signal);
signal = signal + mean(target_signal);

%% Reconstruction
nIterations = 50;

%% Initialization
reconstruction_opt = fill_reconstruction_opt(reconstruction_opt);
reconstruction_opt.signal_update = zeros(size(signal));
if reconstruction_opt.is_verbose
    max_nDigits = 1 + floor(log10(nIterations));
    sprintf_format = ['%',num2str(max_nDigits),'d'];
end
reconstruction_opt.learning_rate = reconstruction_opt.initial_learning_rate;
[target_norm,layer_target_norms] = sc_norm(target_S);

%%
S = cell(1,1+nLayers);
U = cell(1,1+nLayers);
Y = cell(1,1+nLayers);
U{1+0} = initialize_variables_auto(size(signal));
U{1+0}.data = signal;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    Y{layer} = U_to_Y(U{1+previous_layer},arch);
    % Apply non-linearity to last sub-layer Y to get layer U
    U{1+layer} = Y_to_U(Y{layer}{end},arch);
    % Blur/pool first sub-layer Y to get layer S
    S{1+previous_layer} = Y_to_S(Y{layer},arch);
end
Y{1+nLayers}{1+0} = initialize_Y(U{1+nLayers},arch.banks);
S{1+nLayers} = Y_to_S(Y{1+nLayers},arch);

%%
delta_S = sc_substract(target_S,S);
previous_signal = signal;
previous_loss = sc_norm(delta_S);
delta_signal = sc_backpropagate(delta_S,U,Y,archs);

%% Iterated reconstruction
iteration = 0;
tic();
while iteration < nIterations
    %% Signal update
    [signal,reconstruction_opt] = ...
        update_reconstruction(previous_signal,delta_signal,reconstruction_opt);
    
    %% Scattering propagation
    U{1+0}.data = signal;
    for layer = 1:nLayers
        arch = archs{layer};
        previous_layer = layer - 1;
        % Scatter iteratively layer U to get sub-layers Y
        Y{layer} = U_to_Y(U{1+previous_layer},arch);
        % Apply non-linearity to last sub-layer Y to get layer U
        U{1+layer} = Y_to_U(Y{layer}{end},arch);
        % Blur/pool first sub-layer Y to get layer S
        S{1+previous_layer} = Y_to_S(Y{layer},arch);
    end
    Y{1+nLayers}{1+0} = initialize_Y(U{1+nLayers},arch.banks);
    S{1+nLayers} = Y_to_S(Y{1+nLayers},arch);
    
    %% Measurement of distance to target in the scattering domain
    delta_S = sc_substract(target_S,S);
    
    %% If loss has increased, step retraction and bold driver "brake"
    [loss,layer_absolute_distances] = sc_norm(delta_S);
    if loss>previous_loss
        reconstruction_opt.learning_rate = ...
            reconstruction_opt.bold_driver_brake * ...
            reconstruction_opt.learning_rate;
        reconstruction_opt.signal_update = ...
            reconstruction_opt.bold_driver_brake * ...
            reconstruction_opt.signal_update;
        continue
    end
    
    %% If loss has decreased, step confirmation and bold driver "acceleration"
    iteration = iteration + 1;
    previous_signal = signal;
    previous_loss = loss;
    reconstruction_opt.learning_rate = ...
        reconstruction_opt.bold_driver_accelerator * ...
        reconstruction_opt.learning_rate;
    [delta_signal, delta_U] = sc_backpropagate(delta_S,U,Y,archs);
    
    %% Pretty-printing of scattering distances and loss function
    if reconstruction_opt.is_verbose
        mod_iteration = mod(iteration,reconstruction_opt.verbosity_period);
        if mod_iteration==0
            pretty_iteration = sprintf(sprintf_format,iteration);
            relative_loss = 100 * loss / target_norm;
            layer_distances = ...
                100 * layer_absolute_distances ./ layer_target_norms;
            pretty_distances = num2str(layer_distances,'%8.2f%%');
            pretty_loss = sprintf('%.2f%%',relative_loss);
            iteration_string = ['it = ',pretty_iteration,'  ;  '];
            distances_string = ...
                ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
            loss_string = ['Loss = ',pretty_loss];
            disp([iteration_string,distances_string,loss_string]);
            toc();
            tic();
        end
    end
    if reconstruction_opt.is_signal_displayed
        mod_iteration = ...
            mod(iteration,reconstruction_opt.signal_display_period);
        if mod_iteration==0
            sc = display_scalogram(U{1+1});
            save(['scalogram_it',int2str(iteration)], 'sc');
            audiowrite(['cellospiral_it',int2str(iteration),'.wav',], signal, sample_rate);
        end
    end
end

%% Summary
spiral_summary.distances = sc_norm(delta_S);
spiral_summary.reconstruction_opt = reconstruction_opt;
spiral_summary.opts = opts;
spiral_summary.U = U;
spiral_summary.S = S;
spiral_summary.signal = signal;
save('cellospiral_it50_summary','spiral_summary','-v7.3');