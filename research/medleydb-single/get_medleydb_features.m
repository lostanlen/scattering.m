function [X_training, X_validation, X_test] = ...
    get_medleydb_features(archs, dataset_path)
if nargin<2
    dataset_path = '~/datasets/medleydb-single-instruments';
end

%% Get number of features by running the transform on a probe signal
N = archs{1}.banks{1}.spec.size;
S = sc_propagate(randn(N,1), archs);
feature_vector = horzcat(format_layer(S{1+1}, 1), format_layer(S{1+2}, 1));
nFeatures = length(feature_vector);

%% Get features
subfolders = {'training', 'validation', 'test'};
nSubfolders = length(subfolders);
Xs = cell(1, nSubfolders);

for subfolder_index = 1:nSubfolders
    paths = get_medleydb_paths(dataset_path, 'training');
    stem_paths = [paths{:}];
    chunk_paths = [stem_paths{:}];
    nSamples = length(chunk_paths);
    X = zeros(nSamples, nFeatures);
    parfor_progress(nSamples);
    parfor sample_index = 1:nSamples
        chunk_path = chunk_paths{sample_index};
        stereo_waveform = audioread_compat(chunk_path);
        mono_waveform = mean(stereo_waveform, 2);
        S = sc_propagate(mono_waveform, archs);
        X(sample_index, :) = ...
            [format_layer(S{1+1}, 1), format_layer(S{1+2}, 1)].';
        parfor_progress();
    end
    parfor_progress(0);
    Xs{subfolder_index} = X;
end

X_training = Xs{1};
X_validation = Xs{2};
X_test = Xs{3};
end

