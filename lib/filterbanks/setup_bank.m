function bank = setup_bank(bank)
%% Computation of resolutions and bandwidths
bank.metas = fill_bank_metas(bank.spec);

%% Construction of the band-pass filters psi's in time domain
psi_ifts = bank.spec.handle(bank.metas,bank.spec);

%% Fourier transform and spinning
% NB: a wavelet-specific GPU handle should integrate this natively.
signal_dimension = length(bank.spec.size);
psi_fts = multidimensional_fft(psi_ifts,1:signal_dimension);
if bank.spec.has_real_ft
    psi_fts = real(psi_fts);
end
if bank.spec.is_spinned
    psi_fts = spin_psi_fts(psi_fts,signal_dimension);
end

%% Littlewood-Paley renormalization
if strcmp(func2str(bank.spec.handle), 'finitediff_1d')
    psi_energy_sum = sum(psi_fts .* conj(psi_fts),2);
else
    [normalizers,psi_energy_sum] = ...
        get_psi_normalizers(psi_fts,bank.metas,bank.spec);
    if bank.spec.domain.is_ift
        psi_ifts = bsxfun(@rdivide,psi_ifts,normalizers);
    else
        psi_ifts = [];
    end
    if bank.spec.domain.is_ft
        psi_fts = bsxfun(@rdivide,psi_fts,normalizers);
    else
        psi_fts = [];
    end
end

%% Filter "optimization": truncation of negligible values
% Multiple-support filtering is addressed here as well.
bank.psis = optimize_bank(psi_fts,psi_ifts,bank);

%% Construction and trimming of the low-pass filter phi
[phi_ft,energy_sum] = generate_phi_ft(psi_energy_sum,bank.spec);
phi_ift = multidimensional_ifft(phi_ft,1:signal_dimension);
bank.phi = optimize_bank(phi_ft,phi_ift,bank);

%% Generation of dual filter bank if required
if bank.spec.has_duals
    if bank.spec.domain.is_ft
        % If the wavelets are complex in the Fourier domain (e.g.
        % Gammatones), we do in-place conjugation to compute the duals.
        if ~bank.spec.has_real_ft
            psi_fts = conj(psi_fts);
        end
        dual_psi_fts = bsxfun(@rdivide,psi_fts,energy_sum);
    else
        dual_psi_fts = [];
    end
    if bank.spec.domain.is_ift
        dual_psi_ifts = ...
            multidimensional_ifft(dual_psi_fts,1:signal_dimension);
    else
        dual_psi_ifts = [];
    end
    bank.dual_psis = optimize_bank(dual_psi_fts,dual_psi_ifts,bank);
    dual_phi_ft = bsxfun(@rdivide, conj(phi_ft), energy_sum);
    dual_phi = multidimensional_ifft(dual_phi_ft,1:signal_dimension);
    bank.dual_phi = optimize_bank(dual_phi_ft,dual_phi,bank);
end

%% Alphanumeric ordering of field names
bank = orderfields(bank);
