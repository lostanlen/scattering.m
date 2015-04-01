function RLCs = RLC_1d(metas,spec)
resolutions = [metas.resolution];
nGammas = length(resolutions);
original_length = spec.size;
RLCs = zeros(original_length,nGammas);
nPeriods = 1 + spec.periodization_extent;
mother_range_start = 0;
mother_range_end = nPeriods*original_length - 1;
mother_range = (mother_range_start:mother_range_end).';
is_ift_flipped = spec.is_ift_flipped;
mother_xi = spec.mother_xi;
attenuation_factors = mother_xi ./ (2*[metas.quality_factor]);
% This loop can be parallelized
for gamma = 1:nGammas
    resolution = resolutions(gamma);
    range = mother_range * resolution;
    laplace_frequency = 1i * mother_xi - attenuation_factors(gamma);
    exponential = exp(2*pi*laplace_frequency*range);
    RLC = sqrt(resolution) * exponential;
    expanded_RLC = reshape(RLC,original_length,nPeriods);
    if is_ift_flipped
        % Hermitian symmetry
        RLCs([1,end:-1:2],gamma) = conj(sum(expanded_RLC,2));
    else
        RLCs(:,gamma) = sum(expanded_RLC,2);
    end
end
end
