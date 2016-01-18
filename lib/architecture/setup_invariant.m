function invariant = setup_invariant(invariant)
if strcmp(invariant.spec.invariance, 'blurred')
    phi_ift = invariant.spec.invariant_handle(invariant.spec);
    dimension = get_handle_dimension(invariant.spec.invariant_handle);
    phi_ft = multidimensional_fft(phi_ift, 1:dimension);
    if invariant.spec.has_real_ft
        phi_ft = real(phi_ft);
    end
    invariant.phi = optimize_bank(phi_ft, phi_ift, invariant);
    %% Generation of dual low-pass filter if required
    if invariant.spec.has_duals
        dual_phi_ft = conj(phi_ft);
        dual_phi_ift = ...
            multidimensional_ifft(dual_phi_ft, 1:dimension);
        invariant.dual_phi = ...
            optimize_bank(dual_phi_ft, dual_phi_ift, invariant);
    end
end
end

