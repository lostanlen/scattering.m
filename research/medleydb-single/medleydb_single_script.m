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
S = sc_propagate(randn(N,1), archs);
feature_vector = horzcat(format_layer(S{1+1}, 1), format_layer(S{1+2}, 1));
nFeatures = length(feature_vector);

%%
training_paths = get_medleydb_paths(dataset_path, 'training');
stem_paths = [training_paths{:}];
chunk_paths = [stem_paths{:}];
nSamples = length(chunk_paths);

X_train = zeros(nFeatures, nSamples);

%%
fprintf('Progress:\n');
fprintf(['\n' repmat('.',1,m) '\n\n']);

parfor sample_index = 1:nSamples
    chunk_path = chunk_paths{sample_index};
    stereo_waveform = audioread_compat(chunk_path);
    mono_waveform = mean(stereo_waveform, 2);
    S = sc_propagate(mono_waveform, archs);
    X_train(:, sample_index) = ...
        [format_layer(S{1+1}, 1), format_layer(S{1+2}, 1)];
    fprintf('\b|\n');
end