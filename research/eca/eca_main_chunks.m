%% Setup
T = 2^9; % amount of invariance with respect to time translation
Q1 = 8; % number of filters per octave at first order
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'time';
archs = eca_setup(Q1, T, modulations);

%%
audio_path = '/Users/vlostan/datasets/dcase2013/scenes_stereo/tube08.wav';
y = eca_load(audio_path, 200*T);
eca_display(y, archs);

%%
opts.is_displayed = true;
opts.is_sonified = true;

it = eca_synthesize_chunks(y, archs, opts)