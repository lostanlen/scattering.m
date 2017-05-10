% Replace these paths
toolbox_path = '~/scattering.m';
sounds_folder = '~/datasets/eca';

addpath(genpath(toolbox_path));

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
opts.export_mode = 'all'; % should be 'all' or 'last'
opts.nIterations = 20;
opts.generate_text = true; % will work only with time-frequency scattering

% Do not change the parameters below
opts.is_sonified = false;
opts.is_spectrogram_displayed = true;
% (close Figure 1 to abort early)
opts.is_verbose = true;
opts.initial_learning_rate = 0.1;

%% Run re-synthesis for all sounds in sounds_folder
eca_synthesize_dir(archs, sounds_folder, opts)