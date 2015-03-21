function [normalizers,psi_energy_sum] = ...
    get_psi_normalizers(raw_psi_fts,bank_metas,bank_spec)
%% Computation of sum of squared psi energies in frequency domain
signal_dimension = length(bank_spec.size);
gamma_subscript = signal_dimension + 1;
theta_subscript = signal_dimension + 2;
raw_energies = real(raw_psi_fts).^2 + imag(raw_psi_fts).^2;
raw_sum = sum(sum(raw_energies,gamma_subscript),theta_subscript);

%% Interpolation of quality factors
quality_factors = [bank_metas.quality_factor];
if signal_dimension==1
    [~,maximizers] = max(raw_energies(:,:,1));
    half_size = bank_spec.size/2;
    maximizers = maximizers(maximizers<=half_size);
    [unique_maximizers,unique_indices] = unique(maximizers);
    unique_quality_factors = quality_factors(unique_indices);
    mask = unique_maximizers<half_size;
    mirrors = bank_spec.size - unique_maximizers(mask);
    quality_factor_mirrors = unique_quality_factors(mask);
    mirrored_maximizers = [unique_maximizers,mirrors];
    mirrored_quality_factors = ...
        [unique_quality_factors,quality_factor_mirrors];
    range = (1:bank_spec.size).';
    continuous_Q = ...
        interp1(mirrored_maximizers,mirrored_quality_factors,range);
else
    error('psi normalization in dimension >1 not ready yet');
end
continuous_Q(isnan(continuous_Q)) = min(continuous_Q);

%% Normalization of psi energy sum
max_Q = quality_factors(1);
Q_normalizers = continuous_Q./max_Q;
normalized_sum = raw_sum ./ Q_normalizers;
spin_normalizer = 1 - (~bank_spec.is_spinned/2);
energy_normalizer = max(normalized_sum(:));
squared_normalizers = spin_normalizer * energy_normalizer .* Q_normalizers;
normalizers = sqrt(squared_normalizers);
psi_energy_sum = raw_sum ./ squared_normalizers;
end
