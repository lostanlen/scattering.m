function signal = sc_reconstruct(target_signal, archs, reconstruction_opt)
%% Default argument handling
stack_trace = dbstack();
if length(stack_trace)>1
    prefix = default(reconstruction_opt, 'prefix', stack_trace(2).name);
else
    prefix = default(reconstruction_opt, 'prefix', 'summary');
end
signal_sizes = [archs{1}.banks{1}.spec.size,1];
reconstruction_opt = fill_reconstruction_opt(reconstruction_opt);

%% Forward propagation of target signal
nLayers = length(archs);
target_S = cell(1, nLayers);
target_U = cell(1, nLayers);
target_Y = cell(1, nLayers);
target_U{1+0} = initialize_variables_auto(size(target_signal));
target_U{1+0}.data = target_signal;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    if isfield(arch, 'banks')
        target_Y{layer} = U_to_Y(target_U{1+previous_layer}, arch.banks);
    else
        target_Y{layer} = target_U(1+previous_layer);
    end
    
    % Apply nonlinearity to last sub-layer Y to get layer U
    if isfield(arch, 'nonlinearity')
        target_U{1+layer} = Y_to_U(target_Y{layer}{end}, arch.nonlinearity);
    end
    
    % Blur/pool first layer Y to get layer S
    if isfield(arch, 'invariants')
        target_S{1+previous_layer} = Y_to_S(target_Y{layer}, arch);
    end
end

%% Initialization
if isfield(reconstruction_opt, 'initial_signal')
    signal = reconstruction_opt.initial_signal;
else
    signal = generate_colored_noise(target_signal);
end
signal = signal - mean(signal);
signal = signal * norm(target_signal)/norm(signal);
signal = signal + mean(target_signal);

%% First forward
reconstruction_opt.signal_update = zeros(signal_sizes);
max_nDigits = 1 + floor(log10(reconstruction_opt.nIterations));
sprintf_format = ['%0.',num2str(max_nDigits),'d'];
reconstruction_opt.learning_rate = reconstruction_opt.initial_learning_rate;
[target_norm,layer_target_norms] = sc_norm(target_S);
S = cell(1, nLayers);
U = cell(1,nLayers);
Y = cell(1,nLayers);
U{1+0} = initialize_variables_auto(size(signal));
U{1+0}.data = signal;
for layer = 1:nLayers
    arch = archs{layer};
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

%% First backward
delta_S = sc_substract(target_S, S);
previous_signal = signal;
previous_loss = sc_norm(delta_S);
delta_signal = sc_backpropagate(delta_S, U, Y, archs);
light_archs = lighten_archs(archs);

%% Make a snapshot of the target
if reconstruction_opt.snapshot_period ~= 0
    snapshot.datetime = date();
    snapshot.reconstruction_opt = reconstruction_opt;
    snapshot.light_archs = light_archs;
    snapshot.S = target_S;
    snapshot.U1 = target_U{1+1};
    snapshot.Y1 = target_Y{1};
    snapshot.signal = target_signal;
    target_file_name = [prefix, '_target'];
    eval([target_file_name, ' = snapshot;']);
    save(target_file_name, target_file_name);
end

%% Iterated reconstruction
relative_loss_chart = zeros(reconstruction_opt.nIterations, 1);
iteration = 0;
tic();
while iteration < reconstruction_opt.nIterations
    %% Signal update
    [signal,reconstruction_opt] = ...
        update_reconstruction(previous_signal,delta_signal,reconstruction_opt);
    
    %% Scattering propagation
    S = cell(1, nLayers);
    U = cell(1,nLayers);
    Y = cell(1,nLayers);
    U{1+0} = initialize_variables_auto(size(signal));
    U{1+0}.data = signal;
    for layer = 1:nLayers
        arch = archs{layer};
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
    delta_signal = sc_backpropagate(delta_S, U, Y, archs);
    
    %% Pretty-printing of scattering distances and loss function
    if reconstruction_opt.is_verbose
        mod_iteration = mod(iteration,reconstruction_opt.verbosity_period);
        if mod_iteration==0
            pretty_iteration = sprintf(sprintf_format, iteration);
            layer_distances = ...
                100 * layer_absolute_distances ./ layer_target_norms;
            pretty_distances = num2str(layer_distances, '%8.2f%%');
            pretty_loss = sprintf('%.2f%%',relative_loss_chart(iteration));
            iteration_string = ['it = ', pretty_iteration, '  ;  '];
            distances_string = ...
                ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
            loss_string = ['Loss = ', pretty_loss];
            disp([iteration_string, distances_string, loss_string]);
            toc();
            tic();
        end
    end
    mod_iteration = ...
        mod(iteration, reconstruction_opt.snapshot_period);
    if mod_iteration==0
        %% Make snapshot
        snapshot.reconstruction_opt = reconstruction_opt;
        snapshot.light_archs = light_archs;
        snapshot.S = S;
        snapshot.U1 = U{1+1};
        snapshot.Y1 = Y{1};
        snapshot.signal = signal;
        snapshot.relative_loss_chart = relative_loss_chart(1:iteration);
        snapshot.datetime = date();
        pretty_iteration = sprintf(sprintf_format, iteration);
        file_name = [prefix, '_it', pretty_iteration];
        eval([file_name, ' = snapshot;']);
        save(file_name, file_name);
    end
end
toc();
end
