%% Setup
Q1 = 12; % number of filters per octave at first order
T = 2^13; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'morlet';
archs = eca_setup(Q1, T, modulations, wavelets);

%% Load
audio_path = '/Users/vlostan/datasets/eca/modulator_7m04s.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path);
eca_display(y, archs);

%% Re-synthesize
opts.is_sonified = false;
% (close Figure 1 to abort early)
opts.nIterations = 50;
opts.sample_rate = sample_rate; 
opts.generate_text = true;
[sounds, texts] = eca_synthesize(y, archs, opts);

%% Export sounds and text
opts.export_mode = 'all'; % can be 'last' or 'all'
eca_export_sounds(sounds, audio_path, opts, sample_rate, bit_depth, ...
    Q1, T, modulations);
eca_export_texts(texts, audio_path, opts, Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);