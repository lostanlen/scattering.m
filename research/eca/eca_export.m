function eca_export(iterations, audio_path, export_mode, sample_rate)
switch export_mode
    case 'last'
        last_it = length(iterations) - 1;
        suffix = ['_it', num2str(last_it, '%0.3d')];
        last_path = [audio_path(1:(end-4)), suffix, '.wav'];
        audiowrite(last_path, iterations{end}, 44100);
    case 'all'
        nIterations = length(iterations);
        for it = 0:(nIterations-1)
            suffix = ['_it', num2str(it, '%0.3d')];
            it_path = [audio_path(1:(end-4)), suffix, '.wav'];
            audiowrite(it_path, iterations{1+it}, sample_rate);
        end
end
end