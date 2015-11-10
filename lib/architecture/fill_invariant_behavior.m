function behavior = fill_invariant_behavior(opt)
behavior.S.is_invariant = default(opt, 'is_S_invariant', true);
behavior.S.is_bypassed = default(opt, 'is_S_bypassed', false);
end

