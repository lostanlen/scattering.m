function invariant = setup_invariant(invariant)
if strcmp(invariant.spec, 'blurred')
    phi_ift = invariant.spec.handle(invariant.spec);
    phi_ft = multidimensional_fft(phi_ift,1:signal_dimension);
    invariant.phi = optimize_bank(phi_ft,phi_ift,bank);
end
end

