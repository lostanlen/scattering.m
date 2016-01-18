function spec = fill_invariant_spec(opt, bank_spec)
%% Specify default invariant
spec.invariance = default(opt, 'invariance', 'blurred');

%% If a bank specification is available, import size and default T
% The default invariant blurring handle is also specified
if nargin<2
    if strcmp(spec.invariance, 'blurred')
        spec.T = opt.T;
        spec.size = opt.size;
        spec.has_duals = default(opt, 'has_duals', false);
        spec.invariant_handle = ...
            default(opt, 'invariant_handle', @gaussian_1d);
        spec.phi_bw_multiplier = ...
            default(opt, 'phi_bw_multiplier', 2);
        spec.trim_threshold = ...
            default(opt, 'trim_threshold', eps());
        switch func2str(spec.invariant_handle)
            case 'gaussian_1d'
                spec.has_real_ift = true;
                spec.has_real_ft = true;
            case 'gamma_1d'
                spec.has_real_ift = true;
                spec.has_real_ft = false;
            case 'rectangular_1d'
                spec.has_real_ift = true;
                spec.has_real_ft = true;
            otherwise
                disp(spec);
                error('Unknown handle in "invariant.spec".');
        end
    end
    spec.has_multiple_support = default(opt,'has_multiple_support',false);
else
    spec.size = bank_spec.size;
    spec.T = default(opt, 'T', bank_spec.T);
    if strcmp(spec.invariance, 'blurred')
        spec.has_duals = default(opt, 'has_duals', false);
        spec.invariant_handle = default(opt, 'invariant_handle', ...
            default_invariant_handle(bank_spec.wavelet_handle));
        spec.phi_bw_multiplier = ...
            default(spec, 'phi_bw_multiplier', ...
            bank_spec.phi_bw_multiplier);
        spec.trim_threshold = ...
            default(spec, 'trim_threshold', bank_spec.trim_threshold);
        spec.has_real_ft = enforce(opt, 'has_real_ft', bank_spec.has_real_ft);
    end
    spec.has_multiple_support = ...
        default(opt,'has_multiple_support',bank_spec.has_multiple_support);
end
if isfield(spec, 'T')
    spec.J = enforce(opt, 'J', log2(spec.T));
end
%% Alphanumeric ordering of field names
spec = orderfields(spec);
end