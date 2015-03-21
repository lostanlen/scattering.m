function bank_behavior = fill_bank_behavior(opt)
bank_behavior.deepest_sibling_mask_factor = ...
    default(opt,'deepest_sibling_mask_factor',1);
bank_behavior.has_mr_output = default(opt,'has_mr_output',true);
bank_behavior.key = opt.key; % provided in caller
padding = default(opt,'padding','periodic');
bank_behavior.padding = parse_padding(padding);
invariance = default(opt,'invariance','blurred');
bank_behavior.S = parse_invariance(invariance);
bank_behavior.U.is_blurred = default(opt,'is_U_blurred',true);
bank_behavior.U.is_bypassed = default(opt,'is_U_bypassed',false);
bank_behavior.U.is_scattered = default(opt,'is_U_scattered',true);
bank_behavior.U.log2_oversampling = default(opt,'U_log2_oversampling',2);
bank_behavior.S.log2_oversampling = default(opt,'S_log2_oversampling',0);

%% Alphanumeric ordering of field names
bank_behavior = orderfields(bank_behavior);
end
