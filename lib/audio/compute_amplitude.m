function y = compute_amplitude(x)
hilbert_transform = hilbert(x);
analytic_part = x + 1i * hilbert_transform;
y = abs(analytic_part);
end
