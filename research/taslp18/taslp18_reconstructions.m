% Define parameters.
Q1 = 8;
T = 512;
modulations = 'none';
wavelets = 'morlet';
N = 131072;


% Load waveform.
%audio_path = 'taslp18_flute.wav';
audio_path = 'taslp18_dog-bark.wav';
[target_waveform, sample_rate] = taslp18_load(audio_path, N);


% Construct wavelet filter banks.
archs = taslp18_setup(Q1, T, modulations, wavelets, N);


% Compute scattering transform.
[target_S, target_U] = sc_propagate(target_waveform, archs);


target_scalogram = display_scalogram(target_U{1+1});
imagesc(log1p(target_scalogram./10.0));
colormap rev_magma;
axis off;
drawnow();

export_fig(['taslp18_dog-bark_', 'original.png']);

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
