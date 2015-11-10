function behavior = fill_invariant_behavior(opt, bank_behavior)
behavior.S.is_invariant = default(opt, 'is_S_invariant', true);
behavior.S.is_bypassed = default(opt, 'is_S_bypassed', false);
if nargin<2
    behavior.subscripts = default(opt, 'subscripts', bank_behavior);
else
    behavior.subscripts = opt.subscripts;
end
end

