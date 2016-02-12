dataset_path = '~/datasets/medleydb-single-instruments';

%%
N = 131072;
clear opts;
opts{1}.banks.time.nFilters_per_octave = 12;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 32768;
opts{1}.banks.is_chunked = false;
opts{1}.banks.wavelet_handle = @gammatone_1d;
opts{1}.invariants.time.invariance = 'summed';
opts{2}.banks.time.nFilters_per_octave = 2;
opts{2}.banks.gamma.nFilters_per_octave = 1;
opts{2}.banks.gamma.J = 4;
opts{2}.banks.wavelet_handle = @gammatone_1d;
opts{2}.invariants.time.invariance = 'summed';

%% Create architecture
archs = sc_setup(opts);

%%
[X_training, X_test] = get_medleydb_features(archs);
[Y_training, Y_test] = get_medleydb_labels();

%%
data.X_training = X_training;
data.X_test = X_test;
data.Y_training = Y_training;
data.Y_test = Y_test;
data.opts = opts;

mdbjoint_data = data;
save('mdb_joint', 'mdbjoint_data');

%%
classifier_options = statset('UseParallel', true);
NumTrees = 100;
[nSamples_per_class, ~] = hist(Y_training, 0:7);
class_frequencies = nSamples_per_class / sum(nSamples_per_class);
class_weights = 1 ./ class_frequencies;
cost_matrix = repmat(class_weights.', 1, 8) - diag(class_weights);
%%

B = TreeBagger(NumTrees, ...
    X_training, ...
    Y_training, ...
    'Cost', cost_matrix, ...
    'Options', classifier_options);

Y_predicted = predict(B,X_test)
Y_predicted = cellfun(@str2double, Y_predicted);
%%
accuracies = classwise_accuracies(Y_predicted, Y_test)