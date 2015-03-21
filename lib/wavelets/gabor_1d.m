function gabors = gabor_1d(bank_metas,bank_spec)
%% Definition of time range
resolutions = [bank_metas.resolution];
nGammas = length(resolutions);
original_length = bank_spec.sizes;
gabors = zeros(original_length,nGammas);
periodization = bank_spec.periodization_extent*original_length;
nPeriods = 1 + bank_spec.periodization_extent;
mother_range_start = - original_length/2 - periodization/2;
mother_range_end = (original_length/2-1) + periodization/2;
mother_range = (mother_range_start:mother_range_end).';

%% Definition of center frequency xi and variance sigma
% We want the higher center log-frequency in the filter bank, log(mother_xi),
% to be right in between its mirror log(1-mother_xi), and the second higher
% frequency log(2^(-1/N)*mother_xi), where N is the number of filters per
% octave.  Hence the required equality;
% log(1-mother_xi) - log(mother_xi) =  log(2)/N
% of which we easily derive the following formula.
adjacency_ratio = 2^(1/bank_spec.nFilters_per_octave);
mother_xi = 1 / (1+adjacency_ratio);
resolutions = [bank_metas.resolution];

% We want the squared modulus of each Gabor filter psi_lambda to cross
% the filters psi_(lambda-1) and psi_(lambda+1) at half maximum. Hence the
% following full width at half maximum (FWHM) for the mother wavelet. The
% corresponding variance of the mother Gaussian is derived proportionnally.
quality_factors = [bank_metas.quality_factor];
quality_ratios = 2.^(-1./quality_factors);
FWHMs = (1-quality_ratios)./(1+quality_ratios) * mother_xi;
frequential_sigmas = FWHMs / sqrt(log(2));
spatial_sigmas = 1./(2*pi*frequential_sigmas);

%% Computation of Gabor wavelets in the time domain
% This loop is performance-critical. It can already be made parallel.
% MEX-file and GPU implementations should be considered.
subsref_structure = bank_spec.subsref_structure;
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
gabors(:,gamma) = ...
    fast_circshift(periodized_gabor,mother_range_start,subsref_structure);
end
end
