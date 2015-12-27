%% Addpath for Sira
sira_path = ...
    '/Users/ferradans/Documents/Research/AudioSynth/code/toolbox_sparsity/';
addpath(genpath(sira_path));

%% Addpath for Vincent
vincent_path = '~/MATLAB/toolbox_sparsity';
addpath(genpath(vincent_path));

% Setup options
N = 65536;
T = N / 4;
opts{1}.time.T = T;
opts{1}.time.size = N;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 128];

opts{2}.time.T = T;
opts{2}.time.max_scale = Inf;
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.sibling_mask_factor = 2;
opts{2}.time.has_duals = true;
opts{2}.time.max_Q = 1;

% Build filters
archs = sc_setup(opts);

% Load waveform
oboe_path = 'research/sparse-coding/2366.wav';
[waveform, sample_rate] = audioread_compat(oboe_path);

%
target_signal = waveform(100000 + (1:N));

reconstruction_opt = struct();

%% Compute reconstruction
sc_reconstruct(target_signal, archs, reconstruction_opt);

