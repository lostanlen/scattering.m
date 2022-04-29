%%
N = 4096;
J = 8;
Q = 16;
Q_fr = 1;
J_fr = 4;

f1 = 16;
f2 = 512;

t = linspace(0, 1-1/N, N).';
a = (cos(2*pi * f1 * t) + 1) / 2;
c = cos(2*pi * f2 * t);
signal1 = zeros(2*N, 1);
signal1(N/2+1 : end-N/2) = a .* c;

signal2 = zeros(2*N, 1);
signal2(N/2+1 : end-N/2) = cos(2*pi * (20480.^t - 1) * .01);

%%

opts{1}.time = struct( ...
    "size", 2*N, ...
    "T", pow2(J), ...
    "max_Q", Q, ...
    "max_scale", inf, ...
    "is_chunked", false);
opts{2}.time = struct();
opts{2}.gamma = struct( ...
    "T", pow2(J_fr), ...
    "max_Q", Q_fr);

archs = sc_setup(opts);

%%
[S_sig1, U_sig1, Y_sig1] = sc_propagate(signal1, archs);
formatted_sig1 = sc_format(S_sig1);

[S_sig2, U_sig2, Y_sig2] = sc_propagate(signal2, archs);
formatted_sig2 = sc_format(S_sig2);

%%
j2 = 3;
j_fr = 4;

subplot(211);
imagesc(U{3}{1,1}.data{j2}{j_fr}(:,:,1));
caxis([0 max(U{3}{1,1}.data{j2}{j_fr}(:))]);
subplot(212);
imagesc(U{3}{1,1}.data{j2}{j_fr}(:,:,2));
caxis([0 max(U{3}{1,1}.data{j2}{j_fr}(:))]);

%%
opts{1}.time = struct( ...
    "size", N, ...
    "T", pow2(J), ...
    "max_Q", Q, ...
    "max_scale", inf, ...
    "is_chunked", true);
opts{2}.time = struct();
opts{2}.gamma = struct( ...
    "T", pow2(J_fr), ...
    "max_Q", Q_fr);

archs = sc_setup(opts);

[S_sig1, U_sig1, Y_sig1] = sc_propagate([signal1,signal1,signal1], archs);
formatted_sig1 = sc_format(S_sig1);