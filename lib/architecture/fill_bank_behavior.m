function behavior = fill_bank_behavior(opt)
%%
behavior.U.is_blurred = default(opt, 'is_U_blurred', true);
behavior.U.is_bypassed = default(opt, 'is_U_bypassed', false);
behavior.U.is_scattered = default(opt, 'is_U_scattered', true);
behavior.U.log2_oversampling = default(opt, 'U_log2_oversampling', 1);
signal_dimension = length(opt.size); % provided by user
dimension = default(opt, 'dimension', signal_dimension);
behavior.colons = substruct('()', replicate_colon(dimension));
behavior.dimension = dimension;
behavior.S.log2_oversampling = default(opt, 'S_log2_oversampling', 0);
gamma_bounds = default(opt, 'gamma_bounds', [1 Inf]);
if length(gamma_bounds)==1
    gamma_bounds = [gamma_bounds gamma_bounds];
end
behavior.gamma_bounds = gamma_bounds;
behavior.is_sibling_padded = default(opt, 'is_sibling_padded', false);
behavior.is_parallel = default(opt, 'is_parallel', false);
behavior.key = opt.key; % provided in caller setup_plans
behavior.name = opt.name; % provided in caller setup_plans
behavior.output_dimension = opt.output_dimension; % provided in caller
behavior.padding = parse_padding(default(opt, 'padding', 'periodic'));
behavior.sibling_mask_factor = default(opt, 'sibling_mask_factor', 1);
if isfield(opt,'spiral')
    behavior.spiral = opt.spiral;
end
behavior.subscripts = opt.subscripts; % provided in caller setup_plans
if isfield(opt, 'windowing')
    behavior.is_chunked = opt.is_chunked;
    behavior.windowing = opt.windowing;
    behavior.max_minibatch_size = opt.max_minibatch_size;
end

%% Alphanumeric ordering of field names
behavior = orderfields(behavior);
end
