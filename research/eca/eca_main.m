%% Setup
Q1 = 12; % number of filters per octave at first order
T = 32768; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulation = 'none';
archs = eca_setup(Q1, T, modulation);

%% Load
original_path = '~/datasets/eca/modulator_1m28s.wav';
[x, sample_rate] = audioread(original_path);

eca_display(x, archs);

%% Re-synthesize

eca_synthesize(x, archs, opts);