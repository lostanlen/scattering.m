%% Setup
N = 2^17; % 2^17 = 131072, about 3 seconds.
Q1 = 8; % number of filters per octave at first order
T = 2^15; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
modulations = 'time-frequency';
archs = eca_setup(N, Q1, T, modulations);

%% Load
audio_path = '~/datasets/eca/modulator_1m28s.wav';
[y, sample_rate] = audioread(audio_path, 'native');
switch class(y)
    case 'int16'
        bit_depth = 16;
        y = double(y) / 2^16;
    case 'int32'
        bit_depth = 24;
        y = double(y) / 2^32;
end
y = y(1:N);

eca_display(y, archs);

%% Re-synthesize
opts.is_sonified = true;
opts.nIterations = 50;
iterations = eca_synthesize(y, archs, opts);

%% Export
export_mode = 'all'; % can be 'last' or 'all'
eca_export(iterations, audio_path, export_mode, sample_rate, bit_depth, ...
    Q1, T, modulations);
