function phi_ift = gamma_1d(spec)
gamma_order = 1.2;
standard_deviation_multiplier = 0.5;
standard_deviation = spec.T/2 * standard_deviation_multiplier;
alpha = sqrt(gamma_order) / standard_deviation;
full_range = (1:spec.size).';
monomial = full_range.^(gamma_order - 1);
exponential = exp(- alpha * full_range);
phi_ift = monomial .* exponential;
[~, maximum_index] = max(abs(phi_ift));
time_shift = 1 - maximum_index;
phi_ift = circshift(phi_ift, time_shift);
phi_ift = phi_ift / sum(phi_ift);
end