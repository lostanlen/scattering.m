addpath(genpath('../..'));

%% Setup scattering options
Q1 = 12; % number of filters per octave at first order
T = 2^10; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'morlet';
N = 2^16; % length of the signal

% Load
audio_path = '~/datasets/eca/bach.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path, N);

%% Setup reconstruction options
clear opts;
opts.nChunks_per_batch = 2; % must be > 1
opts.is_sonified = false;
opts.is_spectrogram_displayed = true;
% (close Figure 1 to abort early)
opts.nIterations = 50;
opts.sample_rate = sample_rate;
opts.generate_text = false;
opts.is_verbose = false;
opts.initial_learning_rate = 0.1;

%% Multi-chunk mode
archs_multichunk = eca_setup(Q1, T, modulations, wavelets);
sounds_multichunk = eca_synthesize(y, archs_multichunk, opts);

%% Single-chunk mode
archs_singlechunk = eca_setup_1chunk(Q1, T, modulations, wavelets, N);
sounds = eca_synthesize_1chunk(y, archs_singlechunk, opts);

%% Export sounds
opts.export_mode = 'all'; % can be 'last' or 'all'
eca_export_sounds(sounds, audio_path, opts, sample_rate, bit_depth, ...
    Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);