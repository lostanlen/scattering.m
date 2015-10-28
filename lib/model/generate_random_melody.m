function melody_waveform = generate_random_melody(melody_opts, note_opts)
if nargin<2
    note_opts = struct('sample_rate', melody_opts.sample_rate);
end
note_opts = fill_note_opts(note_opts);
%%
nPeriods = 1 + ...
    ceil(note_opts.duration * melody_opts.sample_rate / melody_opts.nSamples);
melody_waveform = zeros(nPeriods * melody_opts.nSamples, 1);
nPitches = 12 * melody_opts.tessitura;

tatum_length = melody_opts.tatum_duration * melody_opts.sample_rate;
nTatums = floor(melody_opts.nSamples / tatum_length);

for onset_index = 1:melody_opts.nOnsets
    tatum = randi(nTatums);
    onset = round(tatum * tatum_length);
    pitch = randi(nPitches) - 1;
    note_opts.fundamental_frequency = ...
        melody_opts.fundamental_frequency * 2^(pitch/12);
    note_waveform = generate_note(note_opts);
    melody_waveform(onset:(onset+length(note_waveform)-1)) = ...
        melody_waveform(onset:(onset+length(note_waveform)-1)) + note_waveform;
end

plot(melody_waveform);
soundsc(melody_waveform,22050);
%%
melody_waveform = reshape(melody_waveform, melody_opts.nSamples, nPeriods);
melody_waveform = sum(melody_waveform, 2);
melody_waveform = 0.1 * melody_waveform / max(abs(melody_waveform));
end

