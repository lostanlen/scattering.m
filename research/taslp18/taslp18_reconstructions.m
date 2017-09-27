% Define parameters.
Q1 = 24;
T = 512;
modulations = 'none';
wavelets = 'morlet';
N = 131072;


% Load waveform.
audio_names = {'taslp18_dog-bark.wav', 'taslp18_flute.wav'};

for audio_name_id = 1:length(audio_names)
    audio_name = audio_names{audio_name_id};
    audio_path = [audio_name, '.wav'];

    [target_waveform, sample_rate] = taslp18_load(audio_path, N);

    % Construct wavelet filter banks.
    archs = taslp18_setup_visualization(Q1, N);

    % Compute scattering transform.
    [target_S, target_U] = sc_propagate(target_waveform, archs);

    target_scalogram = display_scalogram(target_U{1+1});
    imagesc(log1p(target_scalogram./10.0));
    colormap rev_magma;
    axis off;
    drawnow();

    export_fig([audio_name, '_original.png']);

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
