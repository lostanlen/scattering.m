function archs = taslp18_setup(Q1, T, modulations, wavelets, N)
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
opts{1}.time.T = T;
opts{1}.time.max_scale = 8192;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 Q1*9];
opts{1}.time.duality = 'hermitian';
switch wavelets
    case 'morlet'
        opts{1}.time.wavelet_handle = @morlet_1d;
    case 'gammatone'
        opts{1}.time.wavelet_handle = @gammatone_1d;
    otherwise
        error(['Unrecognized field wavelets: ', wavelets]);
end
if strcmp(modulations, 'time') || strcmp(modulations, 'time-frequency')
    % Options for temporal modulations
    opts{2}.time.nFilters_per_octave = 1;
    opts{2}.time.wavelet_handle = @morlet_1d;
    opts{2}.time.duality = 'hermitian';
    switch wavelets
        case 'morlet'
            opts{2}.time.wavelet_handle = @morlet_1d;
        case 'gammatone'
            opts{2}.time.wavelet_handle = @gammatone_1d;
        otherwise
            error(['Unrecognized field wavelets: ', wavelets]);
    end
elseif ~strcmp(modulations, 'none')
    error(['Unrecognized field modulations: ', modulations]);
end
% Options for frequential modulations
if strcmp(modulations, 'time-frequency')
    opts{2}.gamma.duality = 'hermitian';
    opts{2}.gamma.nFilters_per_octave = 1;
    opts{2}.gamma.subscripts = 2;
end
archs = sc_setup(opts);
end
