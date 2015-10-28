function note_waveform = generate_note(note_opts)
%% Default values for note options
note_opts = fill_note_opts(note_opts);

% Initialization to zero
nSamples = round(4 * note_opts.duration * note_opts.sample_rate);
note_waveform = zeros(nSamples, 1);
time_range = (0:(nSamples-1)).' / note_opts.sample_rate;


% Synthesis of partials
for partial_index = 1:note_opts.nPartials
    frequency = note_opts.fundamental_frequency * partial_index;
    amplitude = partial_index^(note_opts.spectral_exponent);
    log_final_amplitude = - 4 * (1 + ...
        note_opts.timbre_velocity * (partial_index-1));
    amplitude_profile = logspace(0, log_final_amplitude, nSamples).';
    note_waveform = note_waveform + ...
        amplitude * amplitude_profile .* cos(2 * pi * frequency * time_range);
end

note_waveform = 0.1 * note_waveform / max(abs(note_waveform));
end

