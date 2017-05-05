function w = hann(N)
t = (0:(N-1)).';
w = 0.5 * (1 - cos(2*pi*t/N));
end

