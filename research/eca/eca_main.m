%% Setup
Q1 = 12; % number of filters per octave at first order
T = 2^13; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'time-frequency';
archs = eca_setup(Q1, T, modulations);

%% Load
audio_path = '/Users/vlostan/Documents/TrENSmissions/expliquer/camille/140806_0804_ech_bear.wav';
[y, sample_rate, bit_depth] = eca_load(audio_path, 12*T);
eca_display(y, archs);

%%
text = eca_text(y, archs, sample_rate);
disp(text)

%% Re-synthesize
opts.is_sonified = true;
% (close Figure 1 to abort early)
opts.nIterations = 50;
iterations = eca_synthesize(y, archs, opts);

%% Export
opts.export_mode = 'all'; % can be 'last' or 'all'
eca_export(iterations, audio_path, opts, sample_rate, bit_depth, ...
    Q1, T, modulations);

%% Clear (run only if necessary)
eca_clear(audio_path, Q1, T, modulations);