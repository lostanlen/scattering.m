function bank_behavior = fill_bank_behavior(opt)
%%
bank_behavior.is_phi_applied = default(opt,'is_phi_applied',false);
bank_behavior.U.log2_oversampling = default(opt,'U_log2_oversampling',1);
signal_dimension = length(opt.size); % provided by user
dimension = default(opt,'dimension',signal_dimension);
bank_behavior.colons = substruct('()',replicate_colon(dimension));
bank_behavior.dimension = dimension;
gamma_bounds = default(opt,'gamma_bounds',[1 Inf]);
if length(gamma_bounds)==1
    gamma_bounds = [gamma_bounds gamma_bounds];
end
bank_behavior.gamma_bounds = gamma_bounds;
bank_behavior.is_sibling_padded = default(opt,'is_sibling_padded',false);
bank_behavior.is_parallel = default(opt,'is_parallel',false);
bank_behavior.key = opt.key; % provided in caller parse_plans
bank_behavior.output_dimension = opt.output_dimension; % provided in caller
bank_behavior.padding = parse_padding(default(opt,'padding','periodic'));
bank_behavior.sibling_mask_factor = default(opt,'sibling_mask_factor',1);
if isfield(opt,'spiral')
    bank_behavior.spiral = opt.spiral;
end
bank_behavior.subscripts = opt.subscripts; % provided in caller setup_plans
end
