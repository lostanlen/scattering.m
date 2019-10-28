N = 32768;
clear opts;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 2^7;
opts{1}.banks.time.max_Q = 24;
opts{1}.banks.time.nFilters_per_octave = 24;
opts{1}.banks.time.max_scale = inf;
opts{1}.banks.time.is_chunked = false;
opts{1}.invariants.time.invariance = 'summed';

opts{2}.banks.time.T = 2^13;
opts{2}.banks.time.max_Q = 1;
Q2 = 1;
opts{2}.banks.time.nFilters_per_octave = Q2;
opts{2}.banks.time.gamma_bounds = [1+10*Q2 1+13*Q2];
opts{2}.invariants.time.invariance = 'summed';
opts{2}.invariants.time.subscripts = [1];
opts{2}.banks.gamma.T = 2^4;
opts{2}.banks.gamma.max_Q = 1;
Q_fr = 4;
opts{2}.banks.gamma.nFilters_per_octave = Q_fr;

Q_oct = 1;
opts{2}.banks.j.nFilters_per_octave = Q_oct;
opts{2}.banks.j.wavelet_handle = @morlet_1d;

opts{2}.invariants.gamma.invariance = 'summed';
opts{2}.invariants.gamma.subscripts = [2];

opts{3}.invariants.time.invariance = 'summed';
opts{3}.invariants.time.subscripts = [1];
opts{3}.invariants.gamma.invariance = 'summed';
opts{3}.invariants.gamma.subscripts = [2];

%
note_times = [ ...
    0.380, 1.050, 2.017, 3.149, 4.143, ...
    4.909, 5.897, 7.084, 8.141, 8.991];

wav_name = 'typicalPETs.wav';
sr = 44100;

n_notes = 1;%length(note_times);

note_time = note_times(note_id);
note_start = round(note_time*sr) - N/2;
waveform = audioread(wav_name);
waveform = waveform(note_start:(note_start+N-1));
waveform = waveform / norm(waveform);

archs = sc_setup(opts);
[S, U] = sc_propagate(waveform, archs);