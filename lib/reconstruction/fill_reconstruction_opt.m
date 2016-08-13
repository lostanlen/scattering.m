function reconstruction_opt = fill_reconstruction_opt(reconstruction_opt)
%% Method
reconstruction_opt.nIterations = ...
    default(reconstruction_opt, 'nIterations', 100);
% It appears that a learning rate of 0.1, which is considered very high
% in machine learning, is a good initial estimate for the reconstruction
% problem. The learning rate policy is subsequently adapted according
% to a bold driver heuristic (see below).
reconstruction_opt.adapt_learning_rate = ...
    default(reconstruction_opt, 'adapt_learning_rate', true);
reconstruction_opt.initial_learning_rate = ...
    default(reconstruction_opt, 'initial_learning_rate', 0.1);
reconstruction_opt.momentum = ...
    default(reconstruction_opt, 'momentum', 0.9);
reconstruction_opt.bold_driver_accelerator = ...
    default(reconstruction_opt, 'bold_driver_accelerator', 1.1);
reconstruction_opt.bold_driver_brake = ...
    default(reconstruction_opt, 'bold_driver_brake', 0.5);

%% Batch computation
reconstruction_opt.nChunks_per_batch = ...
    default(reconstruction_opt, 'nChunks_per_batch', Inf);

%% Regularization
reconstruction_opt.is_regularized = ...
    default(reconstruction_opt, 'is_regularized', ...
    isfield(reconstruction_opt, 'regularizer'));
if reconstruction_opt.is_regularized
    reconstruction_opt.regularized = ...
        default(reconstruction_opt, 'regularizer', 0.1);
end

%% Soft thresholding
if isfield(reconstruction_opt, 'target_min') && ...
        isfield(reconstruction_opt, 'target_max')
    reconstruction_opt.is_thresholded = true;
    reconstruction_opt.soft_thresholding_factor = ...
        default(reconstruction_opt, 'soft_thresholding_factor', 0.1);
else
    reconstruction_opt.is_thresholded = false;
end

%% Verbosity
reconstruction_opt.is_verbose = default(reconstruction_opt, 'is_verbose', true);

%% Display
reconstruction_opt.is_displayed = ...
    default(reconstruction_opt, 'is_displayed', true);

%% Sonification
reconstruction_opt.is_sonified = ...
    default(reconstruction_opt, 'is_sonified', false);

%% Snapshots
reconstruction_opt.snapshot_period = ...
    default(reconstruction_opt, 'snapshot_period', 0);

%% Alphanumeric ordering of field names
reconstruction_opt = orderfields(reconstruction_opt);
end
