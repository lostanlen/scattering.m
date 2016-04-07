function signal = ...
    update_reconstruction(signal, delta_signal, reconstruction_opt)
%% Regularization if required
if reconstruction_opt.is_regularized
    signal = signal - 2 * reconstruction_opt.regularizer * signal;
end

%% Signal update
signal_update = ...
    reconstruction_opt.momentum * reconstruction_opt.signal_update + ...
    reconstruction_opt.learning_rate * delta_signal;
signal = signal + signal_update;

%% Soft thresholding if required
if reconstruction_opt.is_thresholded
    trespassing_signal = (signal<reconstruction_opt.target_min) - ...
        (signal>reconstruction_opt.target_max);
    soft_thresholding_signal = abs(signal) .* trespassing_signal * ...
        reconstruction_opt.soft_thresholding_factor;
    signal = signal - soft_thresholding_signal;
end
end