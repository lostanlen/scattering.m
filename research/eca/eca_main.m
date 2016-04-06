addpath(genpath('~/MATLAB/scattering.m'));

%% Setup
N = 2^17; % = 131072, about 3 seconds. Length
Q1 = 8; % number of filters per octave at first order
T = 2^15; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'none';
archs = eca_setup(Q1, T, modulations);

% Load
original_path = '~/datasets/eca/modulator_1m28s.wav';
[y, sample_rate] = audioread(original_path);

eca_display(y, archs);

%% Re-synthesize
opts.is_displayed = true;
opts.is_sonified = false;
opts.nIterations = 50;
x = eca_synthesize(y, archs, opts);