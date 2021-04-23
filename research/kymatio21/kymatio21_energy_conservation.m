Q = 1;
N = 4096;
J = 10;
Fs = 8000;


opts{1} = default_auditory(N,8000,Q);
opts{2}.time = struct();

archs = sc_setup(opts);

t = linspace(0, 1-1/N, N).';

M = 10;
norms_in = zeros(M, 1);
norms_out = zeros(M, 1);
for j = 1:M
    
    signal = 1 + cos(2*pi * t * 2^(j-1));
    [S, U, Y] = sc_propagate(signal, archs);

    norms_in(j) = norm(signal, 2);
    norms_out(j) = sc_norm(S);
end

bar((1:M)-0.6, norms_out/norms_in, 8)
xlim([-0.5, M]);
ylim([0, 2]);
xlabel('Fundamental frequency of input (log2 scale)');
ylabel('Output-to-input energy ratio');
grid();
 
set(gcf, 'Color', 'w');
%export_fig("kymatio21_energy_conservation.png", "-m4", "-transparent");