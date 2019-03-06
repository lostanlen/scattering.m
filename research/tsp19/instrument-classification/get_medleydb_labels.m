function [Y_training, Y_validation, Y_test] = get_medleydb_labels(dataset_path)
%% Initialize
subfolders = {'training', 'validation', 'test'};
nSubfolders = length(subfolders);
Ys = cell(1, nSubfolders);

%% Get labels
for subfolder_index = 1:nSubfolders
    subfolder = subfolders{subfolder_index};
    paths = get_medleydb_paths(dataset_path, subfolder);
    paths = [paths{:}];
    paths = [paths{:}];
    nSamples = length(paths);
    Y = zeros(nSamples, 1);
    for sample_index = 1:nSamples
        sample_path = paths{sample_index};
        [file_path, ~] = fileparts(sample_path);
        [instrument_path, ~] = fileparts(file_path);
        [~, instrument_name] = fileparts(instrument_path);
        Y(sample_index) = str2double(instrument_name(1:2));
    end
    Ys{subfolder_index} = Y;
end

Y_training = Ys{1};
Y_validation = Ys{2};
Y_test = Ys{3};
end