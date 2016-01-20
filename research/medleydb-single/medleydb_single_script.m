dataset_path = '~/datasets/medleydb-single-instruments';

%%
N = 131072;
clear opts;
opts{1}.banks.time.nFilters_per_octave = 12;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 32768;
opts{1}.invariants.time.invariance = 'summed';
opts{2}.banks.time.nFilters_per_octave = 2;
opts{2}.banks.gamma.nFilters_per_octave = 1;
opts{2}.invariants.time.invariance = 'summed';
archs = sc_setup(opts);

%%


training_paths = get_medleydb_paths(dataset_path, 'training');

stem_paths = [training_paths{:}];
chunk_paths = [stem_paths{:}];

nSamples = length(chunk_paths);

%for sample_index = 1:nSamples
sample_index = 1; 
chunk_path = chunk_paths{sample_index};

[stereo_waveform, sr] = audioread_compat(chunk_path);
mono_waveform = mean(stereo_waveform, 2);
S = sc_propagate(mono_waveform, archs);