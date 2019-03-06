%% Load MAT files
mdbplain_struct = load('mdbplain.mat');
mdbplain_struct = mdbplain_struct.mdbplain_data;

mdbjoint_struct = load('mdbjoint.mat');
mdbjoint_struct = mdbjoint_struct.mdbjoint_data;

%%
mdb_struct = mdbplain_struct;
X_training = mdb_struct.X_training;
X_validation = mdb_struct.X_validation;
X_test = mdb_struct.X_test;
Y_training = mdb_struct.Y_training;
Y_validation = mdb_struct.Y_validation;
Y_test = mdb_struct.Y_test;

%% Standardize features
X_mean = mean(X_training);
X_std = std(X_training);
X_training = bsxfun(@minus, X_training, X_mean);
X_training = bsxfun(@rdivide, X_training, X_std);

X_validation = bsxfun(@minus, X_validation, X_validation);
X_validation = bsxfun(@rdivide, X_validation, X_validation);

X_test = bsxfun(@minus, X_test, X_test);
X_test = bsxfun(@rdivide, X_test, X_test);

X_test_centered = bsxfun(@minus, X_training, X_mean);
X_test_std = bsxfun(@rdivide, X_test, X_std);

%% Estimate weights
[nSamples_per_class, ~] = hist(Y_training, 0:7);
class_frequencies = nSamples_per_class / sum(nSamples_per_class);
class_weights = 1 ./ class_frequencies;
cost_matrix = repmat(class_weights.', 1, 8) - diag(class_weights);

%%
rf_options = statset('UseParallel', true);
nTrees = 50;
B = TreeBagger(nTrees, X_training, Y_training, 'Options', rf_options);
