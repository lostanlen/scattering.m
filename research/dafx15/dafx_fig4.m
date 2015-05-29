%% Loading of target waveform
original_waveform = audioread_compat('sequenza_at3min42.wav');
original_length = length(original_waveform);
N = pow2(nextpow2(original_length));
signal = cat(1,original_waveform,zeros(N-original_length,1));

%% Creation of wavelet filterbank
opts{1}.time.size = length(signal);
opts{1}.time.U_log2_oversampling = 3;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 4096;
archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

%% Computation of wavelet modulus
[~,U] = sc_propagate(signal,archs);

%% Scalogram display
full_scalogram = display_scalogram(U{1+1});

%%
xmin = 68000;
xmax = 441000;
ymin = 10;
ymax = 122;
sub_scalogram = full_scalogram(ymin:ymax,xmin:xmax);

multiplier = 500;
log_scalogram = log1p(multiplier*sub_scalogram);

imagesc(log_scalogram);
colormap rev_gray;
axis off;


%% Export
export_fig dafx_fig4.png -transparent