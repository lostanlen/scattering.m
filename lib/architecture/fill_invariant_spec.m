function invariant_spec = fill_invariant_spec(opt, bank_spec)
invariant_spec = struct('size', bank_spec.size);
if isfield(opt, 'invariance')
    invariant_spec.invariance = opt.invariance;
end 
if isfield(opt, 'T')
    % TODO: integrate max pooling
    enforce(invariant_spec, 'invariance', 'blurred');
    invariant_spec.T = opt.T;
end
if ~isfield(invariant_spec, 'invariance')
    invariant_spec.invariance = 'none';
end
if strcmp(invariant_spec.invariance, 'blurred')
    switch func2str(bank_spec.wavelet_handle)
        case 'morlet_1d'
            invariant_handle = @gaussian_1d;
        case 'gammatone_1d'
            invariant_handle = @gamma_1d;
        case 'finitediff_1d'
            invariant_handle = @rectangular_1d;
    end
    invariant_spec.handle = default(opt, 'invariant_handle', invariant_handle);
end
invariant_spec.phi_bw_multiplier = ...
    default(invariant_spec, 'phi_bw_multiplier', bank_spec.phi_bw_multiplier);

%% Alphanumeric ordering of field names
invariant_spec = orderfields(invariant_spec);
end