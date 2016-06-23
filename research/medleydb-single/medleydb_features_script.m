dataset_path = '~/datasets/mdbsi-val';
methods = { ...
    'time_morlet', 'timefrequency_morlet', 'spiral_morlet', ...
    'time_gammatone', 'timefrequency_gammatone', 'spiral_gammatone', ...
    'time_mixed', 'timefrequency_mixed', 'spiral_mixed'};

%%
N = 131072;
octave_bounds = [2 8];
nfo = 16;
gamma_bounds = [(octave_bounds(1)-1)*nfo octave_bounds(2)*nfo-1];


nMethods = length(methods);
for method_index = 1:nMethods
    method = methods{method_index};
    split_keywords = strsplit(method, '_');
    modulation_keyword = split_keywords{1};
    wavelet_keyword = split_keywords{2};
    clear opts;
    opts{1}.banks.time.nFilters_per_octave = nfo;
    opts{1}.banks.time.size = N;
    opts{1}.banks.time.T = N;
    opts{1}.banks.time.is_chunked = false;
    opts{1}.banks.time.gamma_bounds = gamma_bounds;
    if strcmp(wavelet_keyword, 'morlet')
        opts{1}.banks.time.wavelet_handle = @morlet_1d;
    else
        opts{1}.banks.time.wavelet_handle = @gammatone_1d;
    end
    opts{1}.invariants.time.invariance = 'summed';
    opts{2}.banks.time.nFilters_per_octave = 1;
    if strcmp(wavelet_keyword, 'gammatone')
        opts{2}.time.wavelet_handle = @gammatone_1d;
    else
        opts{2}.banks.time.wavelet_handle = @morlet_1d;
    end
    if strcmp(modulation_keyword, 'timefrequency') || ...
            strcmp(modulation_keyword, 'spiral')
        opts{2}.banks.gamma.nFilters_per_octave = 1;
        opts{2}.banks.gamma.T = 2^5;
    end
    if strcmp(modulation_keyword, 'spiral')
        opts{2}.banks.j.nFilters_per_octave = 1;
    end
    opts{2}.invariants.time.invariance = 'summed';

    file_name = ['mdb_', method];
    var_name = ['mdb_', method, '_data'];

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
    save(file_name, var_name, '-v7.3');
end
