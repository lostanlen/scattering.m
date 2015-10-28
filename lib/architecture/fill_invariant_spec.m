function invariant_spec = fill_invariant_spec(opt)
invariant_spec = struct();
if isfield(opt, 'invariance')
    invariant_spec = opt.invariance;
end 
if isfield(opt, 'T')
    % TODO: integrate max pooling
    enforce(invariant_spec, 'invariance', 'blurred');
end
if ~isfield(invariant_spec, 'invariance')
    invariant_spec.invariance = 'none';
end

