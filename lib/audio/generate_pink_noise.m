function pink_noise = generate_pink_noise(signal_sizes)
signal_dimension = sum(signal_sizes~=1);
switch signal_dimension
    case 1
        spectral_envelope = sqrt(1:signal_sizes).';
        pink_noise_ft = ...
            exp(2i*pi*rand(signal_sizes(1),1)) ./ spectral_envelope;
        pink_noise_analytic = ifft(pink_noise_ft);
        pink_noise_real = real(pink_noise_analytic);
        pink_noise_centered = pink_noise_real - mean(pink_noise_real);
        pink_noise = pink_noise_centered / max(abs(pink_noise_centered));
    case 2
        error('Pink noise generation not ready in dimension 2');
end
end