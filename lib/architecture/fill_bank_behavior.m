function bank_behavior = fill_bank_behavior(opt)
%%
bank_behavior.U.is_blurred = default(opt,'is_U_blurred',true);
bank_behavior.U.is_bypassed = default(opt,'is_U_bypassed',false);
bank_behavior.U.is_scattered = default(opt,'is_U_scattered',true);
bank_behavior.U.log2_oversampling = default(opt,'U_log2_oversampling',1);
bank_behavior.S = parse_invariance(default(opt,'invariance','blurred'));
signal_dimension = length(opt.size); % provided by user
dimension = default(opt,'dimension',signal_dimension);
bank_behavior.colons = substruct('()',replicate_colon(dimension));
bank_behavior.dimension = dimension;
bank_behavior.S.log2_oversampling = default(opt,'S_log2_oversampling',0);
gamma_bounds = default(opt,'gamma_bounds',[1 Inf]);
if length(gamma_bounds)==1
    gamma_bounds = [gamma_bounds gamma_bounds];
end
bank_behavior.gamma_bounds = gamma_bounds;
bank_behavior.has_mr_output = default(opt,'has_mr_output',true);
bank_behavior.is_demodulated = default(opt,'is_demodulated',false);
bank_behavior.is_sibling_padded = default(opt,'is_sibling_padded',false);
bank_behavior.is_parallel = default(opt,'is_parallel',false);
bank_behavior.key = opt.key; % provided in caller parse_plans
bank_behavior.output_dimension = opt.output_dimension; % provided in caller
bank_behavior.padding = parse_padding(default(opt,'padding','periodic'));
bank_behavior.sibling_mask_factor = default(opt,'sibling_mask_factor',1);
if isfield(opt,'spiral')
    bank_behavior.spiral = opt.spiral;
end
bank_behavior.subscripts = opt.subscripts; % provided in caller parse_plans
end
