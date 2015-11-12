function phi_ift = rectangular_1d(spec)
phi_ift = zeros(original_sizes, 1);
half_ift_support = 1:(spec.T/2);
normalizer = sqrt(1+spec.T) * sqrt(3);
phi_ift(1 + half_ift_support) = 1 / normalizer;
phi_ift(1 + end - half_ift_support) = 1 / normalizer;
phi_ift(1+0) = 1 / normalizer;
end