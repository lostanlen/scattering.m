%% Setup
sample_rate = 32000;
required_duration = 0.5; % in seconds
N = 2^(round(log2(required_duration * sample_rate)));
actual_duration = N / sample_rate;
Q1 = 8; % number of filters per octave at first order
T = N/2; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'time';
archs = eca_setup(N, Q1, T, modulations);

%%
audio_path = ...
    '/Users/vlostan/datasets/solosDb_for_ismir2016/04_piano/3581.wav';
y = eca_load(audio_path, 10*N);


%%
opts.is_displayed = true;
opts.is_sonified = false;

it = eca_synthesize_chunks(y, archs, opts)