%% Setup scattering options
Q1 = 12; % number of filters per octave at first order
T = 2^8; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'none';
wavelets = 'morlet';
N = 2^17; % length of the signal

% Load
audio_path = '~/datasets/solosDb/Pn/2985.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path, N);

%% Setup reconstruction options
clear opts;
opts.nChunks_per_batch = 2; % must be > 1
opts.is_sonified = true;
opts.is_spectrogram_displayed = false;
% (close Figure 1 to abort early)
opts.nIterations = 20;
opts.sample_rate = sample_rate;
opts.generate_text = false;
opts.is_verbose = true;
opts.initial_learning_rate = 0.1;

%% Multi-chunk mode
archs_multichunk = eca_setup(Q1, T, modulations, wavelets);
chunk_sounds = eca_synthesize(y, archs_multichunk, opts);

%% Single-chunk mode
archs_singlechunk = eca_setup_1chunk(Q1, T, modulations, wavelets, N);
sounds = eca_synthesize_1chunk(y, archs_singlechunk, opts);

%% Export sounds
opts.export_mode = 'all'; % can be 'last' or 'all'
eca_export_sounds(sounds, audio_path, opts, sample_rate, bit_depth, ...
    Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);