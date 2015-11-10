function behavior = fill_invariant_behavior(opt, bank_behavior)
behavior.S.is_invariant = default(opt, 'is_S_invariant', true);
behavior.S.is_bypassed = default(opt, 'is_S_bypassed', false);
if nargin<2
    behavior.key = default(opt, 'key', bank_behavior.key);
    behavior.subscripts = default(opt, 'subscripts', bank_behavior.key);
else
    behavior.key = opt.key;
    behavior.subscripts = opt.subscripts;
end
end

