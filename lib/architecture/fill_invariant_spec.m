function spec = fill_invariant_spec(opt, bank_spec)
%% Specify default invariant
spec.invariance = default(opt, 'invariance', 'blurred');

%% If a bank specification is available, import size and default T
% The default invariant blurring handle is also specified
if nargin<2
    if strcmp(spec.invariance, 'blurred')
        spec.handle = ...
            default(opt, 'invariant_handle', @gaussian_1d);
        spec.phi_bw_multiplier = ...
            default(opt, 'phi_bw_multiplier', 2);
        spec.trim_threshold = ...
            default(opt, 'trim_threshold', eps());
    end
else
    spec.size = bank_spec.size;
    spec.T = default(opt, 'T', bank_spec.T);
    if strcmp(spec.invariance, 'blurred')
        switch func2str(bank_spec.wavelet_handle)
            case 'morlet_1d'
                invariant_handle = @gaussian_1d;
            case 'gammatone_1d'
                invariant_handle = @gamma_1d;
            case 'finitediff_1d'
                invariant_handle = @rectangular_1d;
        end
        spec.handle = ...
            default(opt, 'invariant_handle', invariant_handle);
        spec.phi_bw_multiplier = ...
            default(spec, 'phi_bw_multiplier', ...
                bank_spec.phi_bw_multiplier);
        spec.trim_threshold = ...
            default(spec, 'trim_thrshold', bank_spec.trim_threshold);
    end
end

%% Alphanumeric ordering of field names
spec = orderfields(spec);
end