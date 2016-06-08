function archs = eca_setup(Q1, T, modulations)
% T is the amount of invariance with respect to temporal translation.
% It should be a power of 2.

% Q1 is the number of filters per octave

% modulations is a string which can either be set to
% 1. 'none' for averaged spectrum only
% 2. 'time' for temporal scattering
% 3. 'time-frequency' for time-frequency scattering

% Options for spectrogram
opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = T;
opts{1}.time.size = 8 * T;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1 Q1*9];
opts{1}.time.duality = 'hermitian';

if strcmp(modulations, 'time') || ...
        strcmp(modulations, 'time-frequency') || ...
        strcmp(modulations, 'spiral')
    % Options for temporal modulations
    opts{2}.time.nFilters_per_octave = 1;
    opts{2}.time.wavelet_handle = @morlet_1d;
    opts{2}.time.duality = 'hermitian';
end
    
% Options for frequential modulations
if strcmp(modulations, 'time-frequency') || strcmp(modulations, 'spiral')
    opts{2}.gamma.duality = 'hermitian';
    opts{2}.gamma.nFilters_per_octave = 1;
    opts{2}.gamma.subscripts = 3;
end

% Options for octave modulations
if strcmp(modulations, 'spiral')
    opts{2}.j.duality = 'hermitian';
    opts{2}.j.nFilters_per_octave = 1;
end

% Setup
archs = sc_setup(opts);
end

