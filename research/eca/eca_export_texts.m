function eca_export_texts(texts, audio_path, opts, Q1, T, modulations)
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
switch opts.export_mode
    case 'last'
        last_it = length(sounds) - 1;
        suffix = [arch_str, '_it=', num2str(last_it, '%0.3d')];
        last_path = [audio_path(1:(end-4)), suffix, '.txt'];
        file_id = fopen(last_path, 'w');
        fprintf(file_id, '%s', texts{end}); 
        fclose(file_id);
    case 'all'
        nIterations = length(texts);
        for it = 0:(nIterations-1)
            suffix = [arch_str, '_it=', num2str(it, '%0.3d')];
            it_path = [audio_path(1:(end-4)), suffix, '.txt'];
            file_id = fopen(it_path, 'w');
            fprintf(file_id, '%s', texts{1+it}); 
            fclose(file_id);
        end
end
end