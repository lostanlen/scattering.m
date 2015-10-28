function gaussian = gaussian_1d(spec)
%% Definition of half support length and haf size
half_support_length = spec.T / 2;
half_size = spec.size / 2;
full_range = fftshift(-half_size:(half_size-1)).';

%% Definition of numerator and denominator in gaussian operand
numerator = - full_range .* full_range;
denominator = half_support_length * half_support_length / log(10);

%% Gaussian
gaussian = exp(numerator / denominator);

%% Normalization
gaussian = gaussian / sum(gaussian);
end

