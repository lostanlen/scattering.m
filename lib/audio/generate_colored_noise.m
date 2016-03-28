function colored_noise = generate_pink_noise(signal)
signal_dimension = sum(signal_sizes~=1);
switch signal_dimension
    case 1
        N = size(signal, 1);
        % Draw phases uniformly at random
        phases = 2 * pi * rand(N, 1);
        spectrum = abs(fft(signal));
        colored_noise = ifft(phases .* spectrum)
    case 2
        error('Colored noise generation not ready in dimension 2');
end
end
