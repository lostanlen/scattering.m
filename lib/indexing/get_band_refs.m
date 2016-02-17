function [band_refs, gamma_bands] = ...
    get_band_refs(archs, hertz_bands, sample_rate)
%% Setup gamma bands
gamma_bounds = archs{1}.banks{1}.behavior.gamma_bounds;
min_gamma = max(gamma_bounds(1), 1);
max_gamma = min(gamma_bounds(2), length(archs{1}.banks{1}.metas));
resolutions = [archs{1}.banks{1}.metas(min_gamma:max_gamma).resolution];
frequencies = archs{1}.banks{1}.spec.mother_xi * sample_rate * resolutions;
nGammas = length(frequencies);

nBands = size(hertz_bands, 2);
gamma_bands = zeros(2, nBands);
for band_index = 1:nBands
    band_min_gamma = (min_gamma - 1) + ...
        find(frequencies < hertz_bands(2, band_index), 1);
    band_min_gamma(isempty(band_min_gamma)) = min_gamma;
    gamma_bands(1, band_index) = band_min_gamma;
    band_max_gamma = (min_gamma - 1) + ...
        find(frequencies > hertz_bands(1, band_index), 1, 'last'); 
    band_max_gamma(isempty(band_max_gamma)) = max_gamma;
    gamma_bands(2, band_index) = band_max_gamma;
end

%% Generate probe signal
N = archs{1}.banks{1}.spec.size;
x = randn(N, 1);
S = sc_propagate(x, archs);

%% Get gammas corresponding to references
refs = generate_refs(S{1+2}{1}.data, 1, S{1+2}{1}.ranges{1+0});
nRefs = length(refs);
ref_gammas = zeros(1, nRefs);

for ref_index = 1:nRefs
    gamma2_index = refs(1, ref_index).subs{1};
    gamma_gamma_index = refs(2, ref_index).subs{1};
    gamma_index = refs(3, ref_index).subs{2};
    gamma_start = S{1+2}{1}.ranges{1+0}{gamma2_index}{gamma_gamma_index}(1, 2);
    gamma_hop = S{1+2}{1}.ranges{1+0}{gamma2_index}{gamma_gamma_index}(2, 2);
    ref_gammas(ref_index) = gamma_start + (gamma_index-1) * gamma_hop;
end

%% Get references corresponding to bands
band_refs = cell(1, nBands);
for band_index = 1:nBands
    gamma_band = gamma_bands(:, band_index);
    band_booleans = ...
        (gamma_band(1) < ref_gammas) & (gamma_band(2) > ref_gammas);
    band_refs{band_index} = find(band_booleans);
end
end

