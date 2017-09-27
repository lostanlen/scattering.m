function archs = taslp18_setup_visualization(Q1, N)
% Q1 is the number of filters per octave.
% N is the length of the input.
% It should be a power of 2.

opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = 2^8;
opts{1}.time.max_scale = Inf;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 Q1*7];
opts{1}.time.duality = 'hermitian';
opts{1}.time.wavelet_handle = @morlet_1d;

archs = sc_setup(opts);
end
