function dict = fill_dict_behavior(opt)
% modeD = false means that atoms are constrained to have unit norm
behavior.modeD = false;
% mode = 1 means that the \ell^1 norm is used to induce sparsity
behavior.mode = 1;
% lambda is the regularization parameter
behavior.lambda = default(opt, 'lambda', 0.15);
% iter is the number of iterations
behavior.iter = default(opt, 'iter', 3000);
% numThreads = -1 means that multithreading is applied if possible
behavior.numThreads = -1;
behavior.verbose = default(opt, 'verbose', true);
end

