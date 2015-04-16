function [signal,summary] = reconstruct(target_S,archs, ...
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
if reconstruction_opt.method.is_momentum
    signal_update = zeros(signal_sizes);
elseif reconstruction_opt.method.is_BFGS
    BFGS = initialize_BFGS(signal_sizes);
end
if reconstruction_opt.is_verbose
    max_nDigits = 1 + floor(log10(nIterations));
    sprintf_format = ['%',num2str(max_nDigits),'d'];
end

%% Iterated reconstruction
for iteration = 0:nIterations-1
    iteration
    plot(signal);
    drawnow;
    
    %% Scattering propagation
    [S,U,Y] = sc_propagate(signal,archs);
    
    %% Measurement of distance to target in the scattering domain
    delta_S = sc_substract(target_S,S);
    
    %% Pretty-printing of scattering distances and loss function
    if reconstruction_opt.is_verbose
        mod_iteration = mod(iteration,reconstruction_opt.verbosity_period);
        if mod_iteration==0
            pretty_iteration = sprintf(sprintf_format,iteration);
            distances = S_norm(delta_S);
            pretty_distances = num2str(distances,'%8.2f%%');
            if reconstruction_opt.is_regularized
                loss = norm(distances) + ...
                    reconstruction_opt.regularizer * norm(signal);
            else
                loss = norm(distances);
            end
            pretty_loss = sprintf('%.2f%%',loss);
            iteration_string = ['it = ',pretty_iteration,'  ;  '];
            distances_string = ...
                ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
            loss_string = ['Loss = ',pretty_loss];
            disp([iteration_string,distances_string,loss_string]);
        end
    end
    if reconstruction_opt.is_spectrum_displayed
        mod_iteration = ...
            mod(iteration,reconstruction_opt.spectrum_display_period);
        if mod_iteration==0
            plot(signal);
            %spectrum = abs(fft(signal));
            %plot(spectrum);
            drawnow;
        end
    end
    
    %% Backpropagation of measured delta to the signal domain
    delta_signal = sc_backpropagate(delta_S,U,Y,archs);
    
    %% Regularization if required
    if reconstruction_opt.is_regularized
        delta_signal = ...
            delta_signal + reconstruction_opt.regularizer * signal;
    end
    
    %% Signal update may be plain gradient descent, momentum-based or BFGS
    if reconstruction_opt.method.is_plain
        signal = signal + reconstruction_opt.learning_rate * delta_signal;
    elseif reconstruction_opt.method.is_momentum
        signal_update = reconstruction_opt.momentum * signal_update + ...
            reconstruction_opt.learning_rate * delta_signal;
        signal = signal + signal_update;
    elseif reconstruction_otp.method.is_BFGS
        BFGS = update_BFGS(BFGS,delta_signal);
        signal = signal + BFGS.s;
    end
    
    %% Soft thresholding if required
    if reconstruction_opt.is_thresholded
        trespassing_signal = (signal<reconstruction_opt.target_min) - ...
            (signal>reconstruction_opt.target_max);
        soft_thresholding_signal = abs(signal) .* trespassing_signal * ...
            reconstruction_opt.soft_thresholding_factor;
        signal = signal + soft_thresholding_signal;
    end
end

%% Make summary
% TODO : summarize bank structure with only specs and behaviors
if nargout>1
    delta_S = cascade_substract(target_S,S);
    summary.distances = S_norm(delta_S);
    summary.reconstruction_opt = reconstruction_opt;
    [summary.S,summary.U] = cascade_propagate(signal,archs);
    summary.signal = signal;
end
end
