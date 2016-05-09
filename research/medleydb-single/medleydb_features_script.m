dataset_path = '~/datasets/mdbsi';
methods = {'plain', 'joint'};

%%
N = 131072;
octave_bounds = [2 8];
nfo = 12;
gamma_bounds = [(octave_bounds(1)-1)*nfo octave_bounds(2)*nfo-1];

nMethods = length(methods);
for method_index = 1:nMethods
    method = methods{method_index};
    clear opts;
    opts{1}.banks.time.nFilters_per_octave = nfo;
    opts{1}.banks.time.size = N;
    opts{1}.banks.time.T = N;
    opts{1}.banks.is_chunked = false;
    opts{1}.banks.gamma_bounds = gamma_bounds;
    opts{1}.banks.wavelet_handle = @gammatone_1d;
    opts{1}.invariants.time.invariance = 'summed';
    opts{2}.banks.time.nFilters_per_octave = 1;
    if strcmp(method, 'joint')
        opts{2}.banks.gamma.nFilters_per_octave = 1;
        opts{2}.banks.gamma.T = 2^5;
    end
    opts{2}.banks.wavelet_handle = @gammatone_1d;
    opts{2}.invariants.time.invariance = 'summed';

    file_name = ['mdb', method];
    var_name = ['mdb', method, '_data'];

    archs = sc_setup(opts);

    [X_training, X_validation, X_test] = ...
        get_medleydb_features(archs, dataset_path);
    [Y_training, Y_validation, Y_test] = get_medleydb_labels(dataset_path);

    data.X_training = X_training;
    data.X_validation = X_validation;
    data.X_test = X_test;
    data.Y_training = Y_training;
    data.Y_validation = Y_validation;
    data.Y_test = Y_test;
    data.opts = opts;
    eval([var_name, ' = data']);
    save(file_name, var_name);
end