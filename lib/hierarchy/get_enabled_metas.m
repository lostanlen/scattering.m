function enabled_metas = ...
    get_enabled_metas(bank_metas,bank_behavior,sibling,uncle)
%%
nGammas = bank_metas(end).gamma;
nPsis = bank_metas(end).gamma;
if (nargin<3) || isempty(sibling)
    enabled_gammas = 1:nGammas;
else
    %%
    sibling_bandwidths = [sibling.metas.bandwidth];
    nGammas = bank_metas(end).gamma;
    factor = bank_behavior.sibling_mask_factor;
    for gamma = nGammas:-1:1
        resolution = bank_metas(gamma).resolution;
        max_sibling_gamma = ...
            find(resolution < factor*sibling_bandwidths,1,'last');
        if ~isempty(max_sibling_gamma)
            bank_metas(gamma).max_sibling_gamma = max_sibling_gamma;
            nFilters_per_octave = sibling.spec.nFilters_per_octave;
            bank_metas(gamma).max_sibling_j = ...
                1 + floor((max_sibling_gamma-1) / nFilters_per_octave);
        else
            break;
        end
    end
    enabled_gammas = (gamma+1):nGammas;
end
gamma_bounds = bank_behavior.gamma_bounds;
gamma_bounds(2) = min(gamma_bounds(2),nPsis);
enabled_gammas = enabled_gammas(enabled_gammas>=gamma_bounds(1));
enabled_gammas = enabled_gammas(enabled_gammas<=gamma_bounds(2));
enabled_metas = bank_metas(enabled_gammas);
end
