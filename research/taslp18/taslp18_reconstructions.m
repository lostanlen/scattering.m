% Define parameters.
Q1 = 24;
T = 512;
modulations = 'none';
wavelets = 'morlet';
N = 131072;


% Load waveform.
audio_names = {'taslp18_dog-bark', 'taslp18_flute'};


% Construct wavelet filter banks.
vis_archs = taslp18_setup_visualization(Q1, N);


for audio_name_id = 1:length(audio_names)
    % Load waveform.
    audio_name = audio_names{audio_name_id};
    audio_path = [audio_name, '.wav'];
    [target_waveform, sample_rate] = taslp18_load(audio_path, N);

    % Compute scattering transform.
    target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
    target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
    target_U1 = Y_to_U(target_Y1{end}, vis_arch{1}.nonlinearity);

    % Display original scalogram.
    target_scalogram = display_scalogram(target_U{1+1});
    imagesc(log1p(target_scalogram./100.0));
    colormap rev_magma;
    axis off;
    drawnow();
    export_fig([audio_name, '_original.png']);
end

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
