function archs = tsp19_setup_visualization(Q1, N)
% Q1 is the number of filters per octave.
% N is the length of the input.
% It should be a power of 2.

nfo = 2*Q1;

opts{1}.time.max_Q = Q1;
opts{1}.time.nFilters_per_octave = nfo;
opts{1}.time.T = 2^8;
opts{1}.time.max_scale = 2048;
opts{1}.time.size = N / 2;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1+nfo*1 nfo*6];
opts{1}.time.wavelet_handle = @morlet_1d;

archs = sc_setup(opts);
end
