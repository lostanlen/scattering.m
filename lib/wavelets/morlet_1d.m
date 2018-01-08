function morlets = morlet_1d(bank_metas,bank_spec)
%% Definition of time range
resolutions = [bank_metas.resolution];
nGammas = length(resolutions);
original_length = bank_spec.size;
morlets = zeros(original_length,nGammas);
periodization = bank_spec.periodization_extent*original_length;
nPeriods = 1 + bank_spec.periodization_extent;
mother_range_start = - original_length/2 - periodization/2;
mother_range_end = (original_length/2-1) + periodization/2;
mother_range = (mother_range_start:mother_range_end).';

%% Definition of center frequency xi and variance sigma
mother_xi = bank_spec.mother_xi;

% We want the squared modulus of each Gabor filter psi_lambda to cross
% the filters psi_(lambda-1) and psi_(lambda+1) at half maximum. Hence the
% following half width at half maximum (HWHM) for the mother wavelet. The
% corresponding variance of the mother Gaussian is derived proportionnally.
quality_factors = [bank_metas.quality_factor];
quality_ratios = 2.^(-1./quality_factors);
half_widths = (1-quality_ratios)./(1+quality_ratios) * mother_xi;
cutoff = 10^(-bank_spec.cutoff_in_dB/20);
frequential_sigmas = half_widths / sqrt(2*log(1/cutoff));
spatial_sigmas = 1./(2*pi*frequential_sigmas);

%% Computation of Morlet wavelets in the time domain
% This loop is performance-critical. It can already be made parallel.
% MEX-file and GPU implementations should be considered.
for gamma = 1:nGammas
    resolution = resolutions(gamma);
    sigma = spatial_sigmas(gamma);
    range = mother_range * resolution;
    numerator = - range.*range;
    denominator = 2 * sigma * sigma;
    ln_gaussian = numerator ./ denominator;
    gaussian = exp(ln_gaussian);
    wave = exp(2i*pi*mother_xi*range);
    gabor = resolution * gaussian .* wave;
    expanded_gabor = reshape(gabor,original_length,nPeriods);
    periodized_gabor = sum(expanded_gabor,2);
    gabor_DC_bias = mean(periodized_gabor);
    expanded_gaussian = reshape(gaussian,original_length,nPeriods);
    periodized_gaussian = sum(expanded_gaussian,2);
    scaling_factor = gabor_DC_bias/mean(periodized_gaussian);
    corrective_term = scaling_factor * periodized_gaussian;
    morlets(:, gamma) = periodized_gabor - corrective_term;
end
end
