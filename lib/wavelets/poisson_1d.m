function poissons = poisson_1d(metas,spec)
resolutions = [metas.resolution];
nGammas = length(resolutions);
original_length = spec.size;
poissons = zeros(original_length,nGammas);
nPeriods = 1 + spec.periodization_extent;
mother_range_start = 0;
mother_range_end = nPeriods*original_length - 1;
mother_range = (mother_range_start:mother_range_end).';
is_ift_flipped = spec.is_ift_flipped;
decay_factor = spec.decay_factor;
mother_xi = spec.mother_xi;
% This loop can be parallelized
for gamma = 1:nGammas
    resolution = resolutions(gamma);
    range = mother_range * resolution;
    laplace_frequency = 1i * mother_xi - decay_factor;
    exponential = exp(2*pi*laplace_frequency*range);
    poisson = sqrt(resolution) * exponential;
    expanded_poisson = reshape(poisson,original_length,nPeriods);
    if is_ift_flipped
        % Hermitian symmetry
        poissons([1,end:-1:2],gamma) = conj(sum(expanded_poisson,2));
    else
        poissons(:,gamma) = sum(expanded_poisson,2);
    end
end
end
