% Script argument:
% * audio_name_str

target_strs = {'dog-bark', 'flute', 'speech'};
Js = [14, 15, 16];
versions = {'time', 'time-frequency'};
suffixes = {'original', 'mcdermott'};

% Define parameters.
N = 131072;

% Construct wavelet filter bank for visualization.
vis_archs = tsp19_setup_visualization(24, N);

for target_str = target_strs
    for J = Js
        for version = versions
            audio_name_str = [ ...
                target_str, '_Q=08_J=', num2str(J), ...
                '_sc=', version, ...
                '_wvlt=morlet_it=100'];
            audio_name_str = [audio_name_str{:}];


            % Load waveform.
            audio_path = [audio_name_str, '.wav'];
            [target_waveform, sample_rate] = tsp19_load(audio_path, N / 2);


            % Compute scalogram.
            target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
            target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
            target_U1 = Y_to_U(target_Y1{end}, vis_archs{1}.nonlinearity);


            % Display original scalogram.
            target_scalogram = display_scalogram(target_U1);
            imagesc(log1p(10*target_scalogram));
            colormap rev_hot;
            axis off;
            drawnow();
            save(audio_name_str, 'target_scalogram');
            export_fig([audio_name_str, '.png']);
        end
    end
    
    
    for suffix = suffixes
        audio_name_str = [target_str, '_', suffix];
        audio_name_str = [audio_name_str{:}];


        % Load waveform.
        audio_path = [audio_name_str, '.wav'];
        [target_waveform, sample_rate] = tsp19_load(audio_path, N / 2);


        % Compute scalogram.
        target_U0 = initialize_U(target_waveform, vis_archs{1}.banks{1});
        target_Y1 = U_to_Y(target_U0, vis_archs{1}.banks);
        target_U1 = Y_to_U(target_Y1{end}, vis_archs{1}.nonlinearity);


        % Display original scalogram.
        target_scalogram = display_scalogram(target_U1);
        imagesc(log1p(10*target_scalogram));
        colormap rev_hot;
        axis off;
        drawnow();
        save(audio_name_str, 'target_scalogram');
        export_fig([audio_name_str, '.png']);
    end
end
