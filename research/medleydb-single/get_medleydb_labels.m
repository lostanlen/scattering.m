function [Y_training, Y_test] = get_medleydb_labels(dataset_path)
if nargin<2
    dataset_path = '~/datasets/medleydb-single-instruments';
end

%% Get training set labels
training_paths = get_medleydb_paths(dataset_path, 'training');
training_paths = [training_paths{:}];
training_paths = [training_paths{:}];
nSamples = length(training_paths);
Y_training = zeros(1, nSamples);
for sample_index = 1:nSamples
    sample_path = training_paths{sample_index};
    [file_path, ~] = fileparts(sample_path);
    [instrument_path, ~] = fileparts(file_path);
    [~, instrument_name] = fileparts(instrument_path);
    Y_training(sample_index) = str2double(instrument_name(1:2));
end

%% Get test set labels
test_paths = get_medleydb_paths(dataset_path, 'test');
test_paths = [test_paths{:}];
test_paths = [test_paths{:}];
nSamples = length(test_paths);
Y_test = zeros(1, nSamples);
for sample_index = 1:nSamples
    sample_path = test_paths{sample_index};
    [file_path, ~] = fileparts(sample_path);
    [instrument_path, ~] = fileparts(file_path);
    [~, instrument_name] = fileparts(instrument_path);
    Y_test(sample_index) = str2double(instrument_name(1:2));
end
end