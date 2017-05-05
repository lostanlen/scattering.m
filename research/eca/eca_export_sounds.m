function eca_export_sounds(sounds, folder, name, opts, sample_rate, ...
    bit_depth, Q1, T, modulations)
switch modulations
    case 'none'
        scattering_str = 'no';
    case 'time'
        scattering_str = 't';
    case 'time-frequency'
        scattering_str = 'tf';
end
arch_str = ...
    ['_Q=', num2str(Q1, '%0.2d'), ...
     '_J=', num2str(log2(T), '%0.2d'), ...
     '_sc=', scattering_str];
folder_out = [folder, arch_str];
if ~exist(folder_out, 'dir')
  mkdir(folder_out);
end
audio_path = fullfile(folder_out, name);
switch opts.export_mode
    case 'last'
        last_it = length(sounds) - 1;
        suffix = [arch_str, '_it=', num2str(last_it, '%0.3d')];
        last_path = [audio_path(1:(end-4)), suffix, '.wav'];
        audiowrite(last_path, sounds{end}, 44100, ...
            'BitsPerSample', bit_depth);
        disp(['Exported last iteration (#', num2str(last_it), ') ', ...
              'at ', last_path, ' (', num2str(bit_depth), ' bits).']);
    case 'all'
        nIterations = length(sounds);
        for it = 0:(nIterations-1)
            suffix = [arch_str, '_it=', num2str(it, '%0.3d')];
            it_path = [audio_path(1:(end-4)), suffix, '.wav'];
            audiowrite(it_path, sounds{1+it}, sample_rate, ...
                'BitsPerSample', bit_depth);
        end
        disp(['Exported iterations 0 to ', num2str(nIterations-1), ' at ', ...
              audio_path(1:(end-4)), arch_str, '_it=*.wav ', ...
              '(', num2str(bit_depth), ' bits).']);
end
end