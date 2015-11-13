function behavior = fill_invariant_behavior(opt, bank_behavior)
behavior.key = opt.key; % provided by caller parse_plans
behavior.S.is_invariant = default(opt, 'is_S_invariant', true);
behavior.S.is_bypassed = default(opt, 'is_S_bypassed', false);
if nargin==2
    behavior.dimension = default(opt, 'dimension', bank_behavior.dimension);
    behavior.subscripts = default(opt, 'subscripts', bank_behavior.subscripts);
    behavior.output_dimension = default(opt, 'output_dimension', ...
        bank_behavior.output_dimension);  
end
behavior.S.log2_oversampling = default(opt, 'S_log2_oversampling', 0);

%% Alphanumeric ordering of field names
behavior = orderfields(behavior);
end

