function dict = fill_dict_params(dict)
% modeD = false means that atoms are constrained to have unit norm
dict.modeD = false;
% mode = 1 means that the \ell^1 norm is used to induce sparsity
dict.mode = 1;
% lambda is the regularization parameter
dict.lambda = default(dict, 'lambda', 0.15);
% iter is the number of iterations
dict.iter = default(dict, 'iter', 3000);
% numThreads = -1 means that multithreading is applied if possible
dict.numThreads = -1;
dict.verbose = default(dict, 'verbose', true);
end