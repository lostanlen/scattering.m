%% Setup
Q1 = 12; % number of filters per octave at first order
T = 2^10; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'gammatone';
archs = eca_setup(Q1, T, modulations, wavelets);

%% Load
audio_path = '/Users/vlostan/datasets/eca/modulator_7m04s.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path);
eca_display(y, archs);

%%
[text, S_sorted_paths] = eca_text(y, archs, sample_rate);
disp(text)

%% Re-synthesize
opts.is_sonified = true;
% (close Figure 1 to abort early)
opts.nIterations = 50;
iterations = eca_synthesize(y, archs, opts);

%% Export
opts.export_mode = 'all'; % can be 'last' or 'all'
eca_export(iterations, audio_path, opts, sample_rate, bit_depth, ...
    Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);