function sc_reconstruct(target_signal, archs, reconstruction_opt)
%% Default argument handling
stack_trace = dbstack();
if length(stack_trace)>1
    prefix = stack_trace(2).name;
else
    prefix = 'summary';
end
signal_sizes = [archs{1}.banks{1}.spec.size,1];
reconstruction_opt = fill_reconstruction_opt(reconstruction_opt);

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
if isfield(reconstruction_opt, 'initial_signal')
    signal = reconstruction_opt.initial_signal;
else
    signal = generate_pink_noise(signal_sizes);
end
signal = signal - mean(signal);
signal = signal * norm(target_signal)/norm(signal);
signal = signal + mean(target_signal);

%% Initialization
reconstruction_opt.signal_update = zeros(signal_sizes);
max_nDigits = 1 + floor(log10(reconstruction_opt.nIterations));
sprintf_format = ['%',num2str(max_nDigits),'d'];
reconstruction_opt.learning_rate = reconstruction_opt.initial_learning_rate;
[target_norm,layer_target_norms] = sc_norm(target_S);
nLayers = length(archs);
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
delta_S = sc_substract(target_S,S);
previous_signal = signal;
previous_loss = sc_norm(delta_S);
delta_signal = sc_backpropagate(delta_S,U,Y,archs);
light_archs = lighten_archs(archs);

%% Iterated reconstruction
relative_loss_chart = zeros(reconstruction_opt.nIterations, 1);
iteration = 0;
tic();
while iteration < reconstruction_opt.nIterations
    %% Signal update
    [signal,reconstruction_opt] = ...
        update_reconstruction(previous_signal,delta_signal,reconstruction_opt);
    
    %% Scattering propagation
    nLayers = length(archs);
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
    relative_loss_chart(iteration) = 100 * loss / target_norm;
    previous_signal = signal;
    previous_loss = loss;
    reconstruction_opt.learning_rate = ...
        reconstruction_opt.bold_driver_accelerator * ...
        reconstruction_opt.learning_rate;
    delta_signal = sc_backpropagate(delta_S,U,Y,archs);
    
    %% Pretty-printing of scattering distances and loss function
    if reconstruction_opt.is_verbose
        mod_iteration = mod(iteration,reconstruction_opt.verbosity_period);
        if mod_iteration==0
            pretty_iteration = sprintf(sprintf_format,iteration);
            layer_distances = ...
                100 * layer_absolute_distances ./ layer_target_norms;
            pretty_distances = num2str(layer_distances,'%8.2f%%');
            pretty_loss = sprintf('%.2f%%',relative_loss_chart(iteration));
            iteration_string = ['it = ',pretty_iteration,'  ;  '];
            distances_string = ...
                ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
            loss_string = ['Loss = ',pretty_loss];
            disp([iteration_string,distances_string,loss_string]);
            toc();
            tic();
        end
    end
    mod_iteration = ...
        mod(iteration,reconstruction_opt.snapshot_period);
    if mod_iteration==0
        %% Make snapshot
        snapshot.reconstruction_opt = reconstruction_opt;
        snapshot.light_archs = light_archs;
        snapshot.S = S;
        snapshot.U1 = U{1+1};
        snapshot.Y = Y{1+1};
        snapshot.signal = signal;
        snapshot.relative_loss_chart = relative_loss_chart(1:iteration);
        pretty_iteration = sprintf(sprintf_format, iteration);
        file_name = [prefix, '_it', pretty_iteration];
        eval([file_name, ' = snapshot']);
        save(file_name, file_name);
    end
end
toc();
end
