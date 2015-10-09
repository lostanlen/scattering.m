function melody_opts = fill_melody_opts(melody_opts)
melody_opts.sample_rate = default(melody_opts, 'sample_rate', 22050); % in Hz
melody_opts.fundamental_frequency = ...
    default(melody_opts, 'fundamental_frequency', 110); % in Hz
melody_opts.tessitura = 2; % in octaves
melody_opts.nSamples = 32768;

end

