%% Setup
N = 2^17; % 2^17 = 131072, about 3 seconds.
Q1 = 8; % number of filters per octave at first order
T = 2^15; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'time-frequency';
archs = eca_setup(N, Q1, T, modulations);

%% Load
audio_path = 'research/gretsi15/Vc-scale-chr-asc.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path, N);
eca_display(y, archs);

%% Re-synthesize
opts.is_sonified = true;
% (close Figure 1 to abort early)
opts.nIterations = 50;
iterations = eca_synthesize(y, archs, opts);

%% Export
export_mode = 'all'; % can be 'last' or 'all'
eca_export(iterations, audio_path, export_mode, sample_rate, bit_depth, ...
    Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);