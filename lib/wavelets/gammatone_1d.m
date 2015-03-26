function gammatones = gammatone_1d(metas,spec)
%% Definition of time range
resolutions = [metas.resolution];
nGammas = length(resolutions);
original_length = spec.size;
gammatones = zeros(original_length,nGammas);
nPeriods = 1 + spec.periodization_extent;
mother_range_start = 0;
mother_range_end = nPeriods*original_length - 1;
mother_range = (mother_range_start:mother_range_end).';

%% Definition of phase shift
mother_xi = spec.mother_xi;
phase_shift = exp(-2i*pi*mother_xi);

%% Computation of the parameter alpha for each wavelet
cutoff = 10^(-spec.cutoff_in_dB/20);
gammatone_order = spec.gammatone_order;
cutoff_root = nthroot(cutoff,gammatone_order);
cutoff_cathetus = 1 - cutoff_root^2;
alpha_multiplier = cutoff_root * gammatone_order * sqrt(cutoff_cathetus);
quality_factors = [metas.quality_factor];
quality_powers = (1 - 2.^(-1./quality_factors));
alpha_qualities = quality_powers / (gammatone_order*cutoff_cathetus);
quality_multipliers = sqrt((sqrt(1+alpha_qualities.^2)-1)/2);
gammatone_alphas = alpha_multiplier * quality_multipliers * mother_xi;

%% Computation of Gammatone wavelets in the time domain
% This loop is performance-critical. It can already be made parallel.
% MEX-file and GPU implementations should be considered.
subsref_structure = substruct('()',{':'});
is_ift_flipped = spec.is_ift_flipped;
for gamma = 1:nGammas
    resolution = resolutions(gamma);
    range = mother_range * resolution;
    alpha = gammatone_alphas(gamma);
    monomial = range.^(gammatone_order-2);
    laplace_frequency = 1i * mother_xi - alpha;
    polynomial = (gammatone_order-1 + laplace_frequency*range) .* monomial;
    exponential = exp(2*pi*laplace_frequency*range);
    gammatone = resolution * polynomial .* exponential;
    [~,maximum_index] = max(abs(gammatone));
    time_shift = 1 - maximum_index;
    shifted_gammatone = phase_shift * ...
        fast_circshift(gammatone,time_shift,subsref_structure);
    expanded_gammatone = ...
        reshape(shifted_gammatone,original_length,nPeriods);
    if is_ift_flipped
        % Hermitian symmetry
        gammatones([1,end:-1:2],gamma) = conj(sum(expanded_gammatone,2));
    else
        gammatones(:,gamma) = sum(expanded_gammatone,2);
    end
end
end