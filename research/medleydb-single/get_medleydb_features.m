function [X_train, X_test] = get_medleydb_features(archs, dataset_path)
if nargin<2
    dataset_path = '~/datasets/medleydb-single-instruments';
end

%% Get number of features by running the transform on a probe signal
S = sc_propagate(randn(N,1), archs);
feature_vector = horzcat(format_layer(S{1+1}, 1), format_layer(S{1+2}, 1));
nFeatures = length(feature_vector);

%% Get training set features
training_paths = get_medleydb_paths(dataset_path, 'training');
stem_paths = [training_paths{:}];
chunk_paths = [stem_paths{:}];
nSamples = length(chunk_paths);
X_train = zeros(nFeatures, nSamples);
parfor sample_index = 1:nSamples
    chunk_path = chunk_paths{sample_index};
    stereo_waveform = audioread_compat(chunk_path);
    mono_waveform = mean(stereo_waveform, 2);
    S = sc_propagate(mono_waveform, archs);
    X_train(:, sample_index) = ...
        [format_layer(S{1+1}, 1), format_layer(S{1+2}, 1)];
    disp(chunk_path)
end

%% Get test set features
test_paths = get_medleydb_paths(dataset_path, 'test');
stem_paths = [test_paths{:}];
chunk_paths = [stem_paths{:}];
nSamples = length(chunk_paths);
X_test = zeros(nFeatures, nSamples);
parfor sample_index = 1:nSamples
    chunk_path = chunk_paths{sample_index};
    stereo_waveform = audioread_compat(chunk_path);
    mono_waveform = mean(stereo_waveform, 2);
    S = sc_propagate(mono_waveform, archs);
    X_test(:, sample_index) = ...
        [format_layer(S{1+1}, 1), format_layer(S{1+2}, 1)];
    disp(chunk_path)
end
end

