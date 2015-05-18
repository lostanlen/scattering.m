function [signal,summary] = sc_reconstruct(target_S,archs, ...
    reconstruction_opt,nIterations,initial_signal)
%% Default argument handling
signal_sizes = [archs{1}.banks{1}.spec.size,1];
if nargin<5
    initial_signal = generate_pink_noise(signal_sizes);
end
if nargin<4
    nIterations = 100;
end
if nargin<3
    reconstruction_opt = fill_reconstruction_opt();
else
    reconstruction_opt = fill_reconstruction_opt(reconstruction_opt);
end

%% Initialization
signal = initial_signal;
reconstruction_opt.signal_update = zeros(signal_sizes);
if reconstruction_opt.is_verbose
    max_nDigits = 1 + floor(log10(nIterations));
    sprintf_format = ['%',num2str(max_nDigits),'d'];
end
reconstruction_opt.learning_rate = reconstruction_opt.initial_learning_rate;
[target_norm,layer_target_norms] = sc_norm(target_S);
[S,U,Y] = sc_propagate(signal,archs);
delta_S = sc_substract(target_S,S);
previous_signal = signal;
previous_loss = sc_norm(delta_S);
delta_signal = sc_backpropagate(delta_S,U,Y,archs);

%% Iterated reconstruction
iteration = 0;
while iteration < nIterations
    %% Signal update
    [signal,reconstruction_opt] = ...
        update_reconstruction(previous_signal,delta_signal,reconstruction_opt);
    
    %% Scattering propagation
    [S,U,Y] = sc_propagate(signal,archs);
    
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
    delta_signal = sc_backpropagate(delta_S,U,Y,archs);
    
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
        end
    end
    if reconstruction_opt.is_signal_displayed
        mod_iteration = ...
            mod(iteration,reconstruction_opt.signal_display_period);
        if mod_iteration==0
            plot(signal);
            drawnow;
        end
    end
end

%% Make summary
% TODO : summarize bank structure with only specs and behaviors
if nargout>1
    delta_S = sc_substract(target_S,S);
    summary.distances = sc_norm(delta_S);
    summary.reconstruction_opt = reconstruction_opt;
    [summary.S,summary.U] = sc_propagate(signal,archs);
    summary.signal = signal;
end
end
