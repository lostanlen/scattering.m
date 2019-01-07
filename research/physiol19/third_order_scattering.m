clear(); clc();

sample_rate = 200; % in Hertz
min_frequency_in_Hertz = 0.1; % in seconds
hop_size_in_seconds = 0.5; % in seconds
Qs = [1, 1, 1]; % quality factor at the first, second, and third layers

x = randn(100000, 1);

T_psi = pow2(nextpow2(sample_rate / min_frequency_in_Hertz));
T_phi = pow2(nextpow2(sample_rate * hop_size_in_seconds)) ;

opts = cell(1, 4);
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


opts{4}.invariants.time.invariance = 'blurred';
opts{4}.invariants.time.T = T_phi;
opts{4}.invariants.time.size = opts{1}.banks.time.size;
opts{4}.invariants.time.subscripts = 1;

archs = sc_setup(opts);

%
S = sc_propagate(x, archs);

%%
% Get first order.
S1_mat = S{1+1}{1}{1}.data;

% Get second order.
S2_mat = [S{1+2}{1}{1}.data{:}];

% Get third order.
J3 = length(S{1+3}{1}{1}.data);
S3_cell = cell(J3, 1);
for j3 = 1:J3
    S3_cell{j3} = [S{1+3}{1}{1}.data{j3}{:}];
end
S3_mat = [S3_cell{:}];

S_mat = cat(2, S1_mat, S2_mat, S3_mat);