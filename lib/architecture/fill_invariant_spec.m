function invariant_spec = fill_invariant_spec(opt, bank_spec)
invariant_spec = struct();
if isfield(opt, 'invariance')
    invariant_spec.invariance = opt.invariance;
end 
if isfield(opt, 'T')
    % TODO: integrate max pooling
    enforce(invariant_spec, 'invariance', 'blurred');
end
if ~isfield(invariant_spec, 'invariance')
    invariant_spec.invariance = 'none';
end
if strcmp(invariant_spec.invariance, 'blurred')
    switch func2str(bank_spec.handle)
        case 'morlet_1d'
            phi_handle = @gaussian_1d;
        case 'gammatone_1d'
            phi_handle = @gamma_1d;
        case 'finitediff_1d'
            phi_handle = @rectangular_1d;
    end
    invariant_spec.handle = default(opt, 'phi_handle', phi_handle);
end
invariant_spec.phi_bw_multiplier = ...
    default(invariant_spec, 'phi_bw_multiplier', bank_spec.phi_bw_multiplier);

%% Alphanumeric ordering of field names
invariant_spec = orderfields(invariant_spec);
end