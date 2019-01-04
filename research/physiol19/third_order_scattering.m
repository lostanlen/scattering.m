sample_rate = 200; % in Hertz
min_frequency_in_Hertz = 0.1; % in seconds
hop_size_in_seconds = 0.5; % in seconds
Qs = [1, 1, 1]; % quality factor at the first, second, and third layers

x = randn(60000, 1);

T_psi = pow2(nextpow2(sample_rate / min_frequency_in_Hertz));
T_phi = pow2(nextpow2(sample_rate * hop_size_in_seconds)) * 2;

opts = cell(1, 3);
opts{1}.banks.time.T = T_psi;
opts{1}.banks.time.max_Q = Qs(1);
opts{1}.banks.time.max_scale = Inf;
opts{1}.banks.time.size = 4*T_psi;
opts{1}.banks.time.is_chunked = true;
opts{1}.banks.time.is_windowed = true;
opts{1}.banks.time.max_minibatch_size = 4;

opts{1}.invariants.time.invariance = 'blurred';
opts{1}.invariants.time.size = opts{1}.banks.time.size;
opts{1}.invariants.time.T = T_phi;

for m = [2, 3]
    opts{m}.banks.time.max_Q = Qs(m);
    opts{m}.banks.time.size = opts{1}.banks.time.size;
    opts{m}.banks.time.T = T_psi;

    opts{m}.invariants.time.invariance = 'blurred';
    opts{m}.invariants.time.T = T_phi;
    opts{m}.invariants.time.size = opts{1}.banks.time.size;
end


archs = sc_setup(opts);

%%
S = sc_propagate(x, archs);
