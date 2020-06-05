clc();
close all;

N = 131072;
clear opts;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 2^11;
opts{1}.banks.time.max_Q = 12;
nfo = 24;
opts{1}.banks.time.nFilters_per_octave = nfo;
opts{1}.banks.time.max_scale = inf;
opts{1}.banks.time.is_chunked = false;
opts{1}.banks.time.wavelet_handle = @morlet_1d;
opts{1}.banks.time.gamma_bounds = [1+round(2.0*nfo) round(7.0*nfo)];
opts{1}.banks.time.gammatone_order = 2;
opts{1}.invariants.time.invariance = 'summed';

opts{2}.banks.time.T = 2^15;
opts{2}.banks.time.max_Q = 1;
Q2 = 4;
opts{2}.banks.time.nFilters_per_octave = Q2;
opts{2}.banks.time.gamma_bounds = [1+10*Q2 15*Q2];
opts{2}.invariants.time.invariance = 'summed';
opts{2}.invariants.time.subscripts = [1];
opts{2}.banks.gamma.T = 2^4;
opts{2}.banks.gamma.max_Q = 1;
Q_fr = 4;
opts{2}.banks.gamma.nFilters_per_octave = Q_fr;
opts{2}.invariants.gamma.invariance = 'summed';
opts{2}.invariants.gamma.subscripts = [2];

opts{3}.invariants.time.invariance = 'summed';
opts{3}.invariants.time.subscripts = [1];
opts{3}.invariants.gamma.invariance = 'summed';
opts{3}.invariants.gamma.subscripts = [2];

archs = sc_setup(opts);

%%


dataset_dir = "~/paperSpontaneousSimilarity/paper/figures/flute_scattering/";
wav_regexp = "*.wav";
dataset_regexp = dataset_dir + wav_regexp;
wav_structs = dir(dataset_regexp);

%%

n_wavs = length(wav_structs);
disp(n_wavs);

for wav_id = 1:n_wavs
    tic();
    wav_folder = wav_structs(wav_id).folder;
    wav_name = wav_structs(wav_id).name;
    wav_path = fullfile(wav_folder, wav_name);
    disp([int2str(wav_id), ' ', wav_path]);
    jasmp20_export_scattering(wav_path, N, archs);
    toc();
end