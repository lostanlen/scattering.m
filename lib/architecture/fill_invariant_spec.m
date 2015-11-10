function invariant_spec = fill_invariant_spec(opt, bank_spec)
%% Specify default invariant
invariant_spec.invariance = default(opt, 'invariance', 'blurred');

%% If a bank specification is available, import size and default T
% The default invariant blurring handle is also specified
if nargin<2
    invariant_spec = opt;
    if strcmp(invariant_spec.invariance, 'blurred')
        invariant_spec.handle = ...
            default(opt, 'invariant_handle', @gaussian_1d);
    end
else
    invariant_spec = struct('size', bank_spec.size);
    invariant_spec.T = default(opt, 'T', bank_spec.T);
    if strcmp(invariant_spec.invariance, 'blurred')
        switch func2str(bank_spec.wavelet_handle)
            case 'morlet_1d'
                invariant_handle = @gaussian_1d;
            case 'gammatone_1d'
                invariant_handle = @gamma_1d;
            case 'finitediff_1d'
                invariant_handle = @rectangular_1d;
        end
        invariant_spec.handle = ...
            default(opt, 'invariant_handle', invariant_handle);
    end
end
invariant_spec.phi_bw_multiplier = ...
    default(invariant_spec, 'phi_bw_multiplier', bank_spec.phi_bw_multiplier);

%% Alphanumeric ordering of field names
invariant_spec = orderfields(invariant_spec);
end