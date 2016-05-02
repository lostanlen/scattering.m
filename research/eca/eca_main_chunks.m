%% Setup
sample_rate = 32000;
required_duration = 0.3; % in seconds
N = 2^(round(log2(required_duration * sample_rate)));
actual_duration = N / sample_rate;
Q1 = 8; % number of filters per octave at first order
T = N/2; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'none';
archs = eca_setup(N, Q1, T, modulations);

%%
audio_path = ...
    '/Users/vlostan/datasets/solosDb_for_ismir2016/04_piano/2970.wav';
y = eca_load(audio_path, 8*N);

%%
opts.adapt_learning_rate = false;
opts.bold_driver_accelerator = 1.0;
opts.initial_learning_rate = 0.1;
opts.is_displayed = true;
opts.is_sonified = true;

it = eca_synthesize_chunks(y, archs, opts)