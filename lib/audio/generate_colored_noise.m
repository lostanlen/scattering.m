function colored_noise = generate_colored_noise(signal)
signal_dimension = sum(size(signal)~=1);
switch signal_dimension
    case 1
        N = size(signal, 1);
        % Draw phases uniformly at random
        phasors = exp(2i * pi * rand(N/2 - 1, 1));
        colored_noise_ft = abs(fft(signal));
        colored_noise_ft(2:(end/2)) = colored_noise_ft(2:(end/2)) .* phasors;
        colored_noise_ft(end:(-1):(end/2+2)) = ...
            colored_noise_ft(end:(-1):(end/2+2)) .* conj(phasors);
        colored_noise = ifft(colored_noise_ft);
    case 2
        error('Colored noise generation not ready in dimension 2');
end
end
