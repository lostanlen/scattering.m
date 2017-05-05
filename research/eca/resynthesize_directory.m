addpath(genpath('~/scattering.m'));
folder = '~/datasets/eca';

%% Setup scattering options
Q1 = 12; % number of filters per octave at first order
T = 2^10; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'morlet';
archs = eca_setup(Q1, T, modulations, wavelets);

%% Setup reconstruction options
clear opts;
opts.nChunks_per_batch = 2; % must be > 1
opts.is_sonified = false;
opts.is_spectrogram_displayed = true;
% (close Figure 1 to abort early)
opts.nIterations = 2;
opts.generate_text = false;
opts.is_verbose = true;
opts.initial_learning_rate = 0.1;

%%
eca_batch_dir(archs, folder, opts)