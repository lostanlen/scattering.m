% In this script, we load a 8-second signal and perform joint scattering.
% First, we display the "scalogram"

%% Load demo signal
load handel;
N = 65536; % length of signal must be a power of 2
Q = 8; % quality factor
signal = y(1:N);

%% Take default values for auditory transform
opts{1} = default_auditory(N,Fs,Q);
% This line adds a second-order transform on top
opts{2}.time = struct();
% This line enables joint time-frequency scattering
opts{2}.gamma = struct(); % gamma means log-frequency

%% Build "architectures" (filter banks)
archs = sc_setup(opts);

%% Compute scattering representation
[S,U,Y] = sc_propagate(signal,archs);

%% Display scalogram (wavelet transform modulus)
U_unchunked = sc_unchunk(U);
scalogram = U_unchunked{1+1};
subplot(211);
display_scalogram(scalogram);

%% Display second-order spectrum at given scale
modulation_scale_index = 4;
scattergram = U_unchunked{1+2}.data{modulation_scale_index}.';
subplot(212);
imagesc(scattergram);
