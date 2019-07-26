%% Setup wavelet filterbanks.
% Import toolboxes.
clc();
clear();

addpath(genpath('~/scattering.m'));

syn_dir = '~/lostanlen2019_dafx';
syn_names = { ...
    'Syn_21845_channel_001.spl_53_J-15_Q-6_it-100.wav', ...
    'Syn_21845_channel_001.spl_65_J-14_Q-24_it-050.wav', ...
    'Syn_21845_channel_003.spl_58_J-14_Q-24_it-030.wav', ...
    'Syn_21845_channel_003.spl_58_J-15_Q-6_it-050.wav' ...
};
n_names = length(syn_names);

N = 2^20;
Q1 = 8;
nfo = 2*Q1;
J = 11;
T = 2^J;

opts = {};
opts{1}.time.T = T;
opts{1}.time.max_scale = Inf;
opts{1}.time.max_Q = Q1;
opts{1}.time.nFilters_per_octave = nfo;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 nfo*6];

archs = sc_setup(opts);

%
% Synthesize chirps.
name_id = 2;
syn_path = fullfile(syn_dir, syn_names{name_id});
x = eca_load(syn_path, N);
S = sc_propagate(x, archs);

scalogram = S{1+1}.data.';
imagesc(log1p(1e-3*scalogram));
colormap rev_magma;