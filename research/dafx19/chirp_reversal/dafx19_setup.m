function archs = dafx19_setup(N, Q1, T)

opts{1}.time.T = T;
opts{1}.time.max_scale = Inf;
opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 Q1*3];
opts{1}.time.duality = 'hermitian';
opts{1}.time.wavelet_handle = @morlet_1d;

opts{2}.time.nFilters_per_octave = 1;
opts{2}.time.wavelet_handle = @morlet_1d;
opts{2}.time.duality = 'hermitian';
opts{2}.time.wavelet_handle = @morlet_1d;

opts{2}.gamma.duality = 'hermitian';
opts{2}.gamma.nFilters_per_octave = 1;
opts{2}.gamma.subscripts = 2;

archs = sc_setup(opts);
end