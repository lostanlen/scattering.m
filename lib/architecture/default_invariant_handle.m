function invariant_handle = default_invariant_handle(wavelet_handle)
switch func2str(wavelet_handle)
    case 'morlet_1d'
        invariant_handle = @gaussian_1d;
    case 'gammatone_1d'
        invariant_handle = @gamma_1d;
    case 'finitediff_1d'
        invariant_handle = @rectangular_1d;
end