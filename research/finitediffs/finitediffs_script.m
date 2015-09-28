%% Build scattering "architectures", i.e. filter banks and nonlinearities
opts{1}.time.size = 65536;
opts{1}.time.T = 2^10;
opts{1}.time.max_scale = 16*opts{1}.time.T;
opts{1}.time.nFilters_per_octave = 16;

% Options for scattering along time
opts{2}.time.handle = @morlet_1d;
opts{2}.time.max_scale = Inf;
opts{2}.time.U_log2_oversampling = 2;

% Options for scattering along chromas
opts{2}.gamma.invariance = 'bypassed';
opts{2}.gamma.U_log2_oversampling = Inf;

% Options for scattering along octaves
opts{2}.j.invariance = 'bypassed';
opts{2}.j.handle = @finitediff_1d;

% Build scattering "architectures", i.e. filter banks and nonlinearities
archs = sc_setup(opts);


