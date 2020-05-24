function eca_export(sounds, texts, folder, name, opts, sample_rate, ...
    bit_depth, archs)
%% Renormalize sounds
renormalizer = 2 * max([cellfun(@max, sounds), -cellfun(@min, sounds)]);
nSounds = length(sounds);
for sound_id = 1:nSounds
    sounds{sound_id} = sounds{sound_id} / renormalizer;
end

%% Retrieve parameters
Q1 = archs{1}.banks{1}.spec.nFilters_per_octave;
T = archs{1}.banks{1}.spec.T;
if length(archs) == 2
    modulations = 'none';
else
    switch length(archs{2}.banks)
        case 1
            modulations = 'time';
        case 2
            modulations = 'time-frequency';
        case 3
            modulations = 'spiral';
    end
end
wavelet_handle_str = func2str(archs{1}.banks{1}.spec.wavelet_handle);
switch wavelet_handle_str
    case 'morlet_1d'
        wavelet_str = 'mor';
    case 'gammatone_1d'
        wavelet_str = 'gam';
end

%% Generate arch_str
switch modulations
    case 'none'
        scattering_str = 'no';
    case 'time'
        scattering_str = 't';
    case 'time-frequency'
        scattering_str = 'tf';
    case 'spiral'
        scattering_str = 'sp';
end
arch_str = ...
    ['_Q=', num2str(Q1, '%0.2d'), ...
     '_J=', num2str(log2(T), '%0.2d'), ...
     '_sc=', scattering_str, ...
     '_wvlt=', wavelet_str];
folder_out = [folder, arch_str];
if ~exist(folder_out, 'dir')
    mkdir(folder_out);
end
audio_path = fullfile(folder_out, name);
generate_text = opts.generate_text;
switch opts.export_mode
    case 'last'
        last_it = length(sounds) - 1;
        suffix = [arch_str, '_it=', num2str(last_it, '%0.3d')];
        last_path = [audio_path(1:(end-4)), suffix, '.wav'];
        audiowrite(last_path, sounds{end}, sample_rate, ...
            'BitsPerSample', bit_depth);
        if generate_text
            last_path = [audio_path(1:(end-4)), suffix, '.txt'];
            file_id = fopen(last_path, 'w');
            fprintf(file_id, '%s', texts{end}); 
            fclose(file_id);
        end
        disp(['Exported last iteration (#', num2str(last_it), ') ', ...
              'at ', last_path, ...
              ' (', num2str(sample_rate), ' Hz, ', ...
              num2str(bit_depth), ' bits).']);
    case 'all'
        nIterations = length(sounds);
        for it = 0:(nIterations-1)
            suffix = [arch_str, '_it=', num2str(it, '%0.3d')];
            it_path = [audio_path(1:(end-4)), suffix, '.wav'];
            audiowrite(it_path, sounds{1+it}, sample_rate, ...
                'BitsPerSample', bit_depth);
            if generate_text
                it_path = [audio_path(1:(end-4)), suffix, '.txt'];
                file_id = fopen(it_path, 'w');
                fprintf(file_id, '%s', texts{1+it}); 
                fclose(file_id);
            end
        end
        disp(['Exported iterations 0 to ', num2str(nIterations-1), ' at ', ...
              audio_path(1:(end-4)), arch_str, '_it=*.wav ', ...
              ' (', num2str(sample_rate), ' Hz, ', ...
              num2str(bit_depth), ' bits).']);
end
end