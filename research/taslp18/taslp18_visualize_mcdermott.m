% Script argument:
% * audio_name_str

% Define parameters.
N = 131072;
mcdermott_sr = 20000;
target_sr = 22050;


% Construct wavelet filter bank for visualization.
vis_archs = taslp18_setup_visualization(24, N);


% Load waveform.
audio_path = ['media/', audio_name_str, '_11111110111.wav'];
target_waveform = taslp18_load(audio_path, mcdermott_sr / target_sr * N / 2);
target_waveform = resample(target_waveform, target_sr, mcdermott_sr);
sample_rate = mcdermott_sr;


% Compute scalogram.
target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
target_U1 = Y_to_U(target_Y1{end}, vis_archs{1}.nonlinearity);


% Display original scalogram.
target_scalogram = display_scalogram(target_U1);
imagesc(log1p(target_scalogram));
colormap rev_magma;
axis off;
drawnow();
export_fig(['media/', audio_name_str, '_mcdermott.png']);
