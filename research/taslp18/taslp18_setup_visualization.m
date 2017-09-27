function archs = taslp18_setup_visualization(Q1, T, wavelets, N)
% T is the amount of invariance with respect to temporal translation.
% It should be a power of 2.

% Q1 is the number of filters per octave.

% modulations is a string which can either be set to
% 1. 'none' for averaged spectrum only
% 2. 'time' for temporal scattering
% 3. 'time-frequency' for time-frequency scattering

% wavelets is either 'morlet' or 'gammatone'.

% N is the length of the input.
% It should be a power of 2.

opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = 2^8;
opts{1}.time.max_scale = 1024;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 Q1*7];
opts{1}.time.duality = 'hermitian';
switch wavelets
    case 'morlet'
        opts{1}.time.wavelet_handle = @morlet_1d;
    case 'gammatone'
        opts{1}.time.wavelet_handle = @gammatone_1d;
    otherwise
        error(['Unrecognized field wavelets: ', wavelets]);
end

archs = sc_setup(opts);
end
