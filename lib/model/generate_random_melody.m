function melody_waveform = generate_random_melody(melody_opts, note_opts)
if nargin<2
    note_opts = struct();
end
note_opts = fill_note_opts(note_opts);

melody_waveform = zeros(2 * melody_opts.nSamples, 1);


for onset_index = 1:melody_opts.nOnsets
    onset = randi(nSamples);
    fundamental_frequency
end

melody_waveform = melody_waveform(1:(end/2)) + melody_waveform(1+end/2):end);
melody_waveform = 0.1 * melody_waveform / max(abs(melody_waveform));
end

