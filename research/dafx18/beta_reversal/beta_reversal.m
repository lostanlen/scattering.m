N = 65536;
sample_rate = 16000;
inter_onset_interval = N / 16;
chirp_locations = [1, 2, 4, 5, 6, 8, 10, 11]; % in 16th of the signal
chirp_frequencies = [1, 1, 1, 1, 1, 1, 1, 1]; % in kHz
chirp_durations = [1, 1, 1, 1, 1, 1, 1, 1]; % in 16th of the signal
chirp_spans = [1, 1, 1, 1, 1, 1, 1, 1]; % in octaves
tukey_alpha = 0.5;
n_chirps = length(chirp_locations);


% Generate original waveform as a combination of chirps.
target_waveform = zeros(N, 1);
for chirp_id = 1:n_chirps
    chirp_location = chirp_locations(chirp_id);
    chirp_frequency = chirp_frequencies(chirp_id);
    chirp_duration = chirp_durations(chirp_id);
    chirp_span = chirp_spans(chirp_id);

    chirp_length = chirp_duration * inter_onset_interval;
    t = 1:chirp_length;
    f_start = 1000 * chirp_frequency * chirp_span * 2^(-chirp_span/2);
    f_stop = 1000 * chirp_frequency *  chirp_span * 2^(chirp_span/2);
    instantaneous_frequency = ...
        transpose(logspace(log10(f_start), log10(f_stop), chirp_length));
    instantaneous_phase = cumsum(instantaneous_frequency);
    tukey_window = tukeywin(chirp_length, tukey_alpha);
    chirp = tukey_window .* cos(2*pi * instantaneous_phase / sample_rate);
    chirp_start = (chirp_location - chirp_duration/2) * inter_onset_interval;
    chirp_stop = chirp_start + chirp_duration * inter_onset_interval - 1;
    target_waveform(chirp_start:chirp_stop) = ...
        target_waveform(chirp_start:chirp_stop) + chirp;
end


% Export original waveform.
target_waveform = 0.1 * target_waveform / max(target_waveform);
audiowrite('beta_reversal_original.wav', target_waveform, sample_rate);


% Compute time-frequency scattering.
Q = 12;
T = inter_onset_interval
opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = T;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.duality = 'hermitian';
opts{1}.time.gamma_bounds = [1+Q1*1 Q1*6];
opts{1}.time.wavelet_handle = @morlet_1d;
opts{2}.invariants.time.T = T;
opts{2}.invariants.time.size = N;
opts{2}.invariants.time.subscripts = [1];
opts{2}.invariants.time.duality = 'hermitian';
opts{2}.banks.time.nFilters_per_octave = 1;
opts{2}.banks.time.wavelet_handle = @morlet_1d;
opts{2}.banks.time.duality = 'hermitian';
opts{2}.banks.time.T = T;
opts{2}.banks.time.wavelet_handle = @morlet_1d;
opts{2}.banks.gamma.xi = 1/3;
opts{2}.banks.gamma.T = 2^3;
opts{2}.banks.gamma.duality = 'hermitian';
opts{2}.banks.gamma.nFilters_per_octave = 1;
opts{2}.banks.gamma.subscripts = 2;
archs = sc_setup(opts);
