% Order 1 along time
opts{1}.time.T = 2048;
opts{1}.time.max_scale = 4096; % about 93 ms
opts{1}.time.max_Q = 8;
 
% Nonlinearity between the two orders
opts{1}.nonlinearity.name = 'modulus';
 
% Order 2 in time
opts{2}.time.handle = @gammatone_1d;

%% Build filters
archs = sc_setup(opts);

%% Load waveform
oboe_path = 'research/sparse-coding/2366.wav';
[waveform, sample_rate] = audioread_compat(oboe_script);

%% Compute scattering


