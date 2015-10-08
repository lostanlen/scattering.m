function note_opts = fill_note_opts(note_opts)
note_opts.duration = ...
    default(note_opts, 'duration', 1.0); % in seconds
note_opts.fundamental_frequency = ...
    default(note_opts, 'fundamental_frequency', 440); % in Hz
note_opts.nPartials = default(note_opts, 'nPartials', 8);
note_opts.sample_rate = default(note_opts, 'sample_rate', 22050);
note_opts.spectral_exponent = default(note_opts, 'spectral_exponent', 0);
note_opts.timbre_velocity = default(note_opts, 'timbre_velocity', 1.0);
end

