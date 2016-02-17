%%
clear opts;
hertz_bands = ...
    [125 250 ; ...
    200 500 ; ...
    400 1000 ; ...
    800 2000 ; ...
    1600 4000 ; ...
    3200 8000 ; ...
    7200 16000].';
sample_rate = 44100;
nFilters_per_octave = 12;
ROI_duration = 1.0; % in seconds
nTemporal_modulations = 14;
nSpectral_modulations = 2;


%
T = pow2(nextpow2(round(ROI_duration * sample_rate)));

opts{1}.time.nFilters_per_octave = nFilters_per_octave;
opts{1}.time.T = T;
opts{1}.time.size = 4*T;

opts{2}.time.nFilters_per_octave = 1;
opts{2}.time.sibling_mask_factor = 2; % controls the inequality j1 < j2
opts{2}.time.T = 2^nTemporal_modulations;
opts{2}.gamma.T = 2^nSpectral_modulations;
opts{2}.gamma.U_log2_oversampling = Inf;

archs = sc_setup(opts);
[band_refs, gamma_bands] = get_band_refs(archs, hertz_bands, sample_rate);

%%
gamma_min = min(gamma_bands(:));
gamma_max = max(gamma_bands(:));
archs{1}.banks{1}.behavior.gamma_bounds = [gamma_min gamma_max];
[band_refs, gamma_bands] = get_band_refs(archs, hertz_bands, sample_rate);

%%
waveform_path = '~/datasets/minibird/15/LIFECLEF2014_BIRDAMAZON_XC_WAV_RN1147.wav';
[waveform, sample_rate] = audioread_compat(waveform_path);
x = waveform(1:300000);

S = sc_propagate(x, archs);

%% Stack scattering coefficients according to bands
nBands = length(band_refs);
bands = cell(1, nBands);
nTime_frames = length(S{1+2}{1}.data{1}{1});
refs = generate_refs(S{1+2}{1}.data, 1, S{1+2}{1}.ranges{1+0});
for band_index = 1:nBands
    nCoefficients = length(band_refs{band_index});
    band = zeros(nTime_frames, nCoefficients);
    for coefficient_index = 1:nCoefficients
        ref = refs(:, band_refs{band_index}(coefficient_index));
        band(:, coefficient_index) = subsref(S{1+2}{1}.data, ref);
    end
    bands{band_index} = band;
end

%%
