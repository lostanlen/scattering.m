function w = planck_taper(N, epsilon)
if nargin < 2
    epsilon = 0.1;
end
%%
x = linspace(0, 1, N);
Z_plus = epsilon ./ x + epsilon ./ (x - epsilon);
Z_minus = - epsilon ./ (x - (1-epsilon)) - epsilon ./ (x - 1);
w = ones(N, 1);
t2 = round(epsilon * N);
t3 = round((1-epsilon) * N);
w(1) = 0;
w(2:t2) = 1 ./ (exp(Z_plus(2:t2)) + 1);
w((t3+1):end-1) = 1 ./ (exp(Z_minus((t3+1):end-1)) + 1);
w(end) = 0;
plot(w);
end
