function x = dafx_synthesize_chirps(N)

sample_rate = 4000;

%chirp_amplitudes = ones(1, 12);
chirp_amplitudes = [4, 1, 1, 0, 2, 1, 0, 2, 0, 1, 2, 0];
%chirp_amplitudes = [1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0];
chirp_frequencies = ones(1, 12);

%chirp_durations = [1, 1, 2, 0, 1, 2, 0, 2, 0, 1, 2, 0];
chirp_durations = 1.0 * ones(1, 12);

%chirp_spans = ones(1, 12);
chirp_spans = [ 1,  1,  2,  0,  1,  2,  0,  2,  0,  1,  2,  0] * 0.5;
chirp_signs = [-1, -1,  1,  0, -1,  1,  0,  1,  0, -1,  1,  0];

n_chirps = length(chirp_amplitudes);
inter_onset_interval = round(N / n_chirps);

% Generate original waveform as a combination of chirps.
x = zeros(N*1.5, 1);
for chirp_id = 1:n_chirps
    chirp_amplitude = chirp_amplitudes(chirp_id);
    chirp_frequency = chirp_frequencies(chirp_id);
    chirp_duration = chirp_durations(chirp_id);
    chirp_span = chirp_spans(chirp_id);
    chirp_sign = chirp_signs(chirp_id);

    chirp_length = chirp_duration * inter_onset_interval;
    f_start = 880 * chirp_frequency * 2^(-chirp_sign*chirp_span/2);
    f_stop = 880 * chirp_frequency * 2^(chirp_sign*chirp_span/2);
    instantaneous_frequency = ...
        transpose(logspace(log10(f_start), log10(f_stop), chirp_length));
    instantaneous_phase = cumsum(instantaneous_frequency);
    hann_window = hann(chirp_length);
    chirp = chirp_amplitude * ...
        hann_window .* cos(2*pi * instantaneous_phase / sample_rate);
    
    chirp_start = ...
        1 + round((chirp_id - 0.5 - chirp_duration/2) * inter_onset_interval);
    chirp_stop = chirp_start + ...
        round(chirp_duration * inter_onset_interval) - 1;
    x(chirp_start:chirp_stop) = ...
        x(chirp_start:chirp_stop) + chirp;
end

x = x(1:N);

% Export original waveform.
x = 0.1 * x / max(x);
end