% Reproduit la figure 3a de la soumission au GRETSI 2015
% Vincent Lostanlen, Stephane Mallat.
% "Transformee de scattering en spirale temps-chroma-octave"

%% Loading of target waveform
signal = audioread_compat('lion.wav');

%% Creation of wavelet filterbank
opts{1}.time.size = length(signal);
opts{1}.time.U_log2_oversampling = Inf;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 1024;
archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

%% Computation of wavelet modulus
[~,U] = sc_propagate(signal,archs);

%% Scalogram display
display_scalogram(U{1+1});
colormap rev_hot;
axis off;

%% Export
% export_fig gretsi_fig3a.png -transparent
