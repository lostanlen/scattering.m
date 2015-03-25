function bank = sibling_scatter_bank(bank,sibling,uncle)
%%
if nargin<3
    uncle = [];
end
bank.metas = get_enabled_metas(bank.metas,bank.behavior,sibling,uncle);
nEnabled_gammas = length(bank.metas);
sibling_gammas = [sibling.metas.gamma];
sibling_log2_samplings = [sibling.metas.log2_sampling];
log2_oversampling = bank.behavior.U.log2_oversampling;
log2_factor = ceil(log2(bank.behavior.sibling_mask_factor));
log2_resamplings = cell(nEnabled_gammas,1);
for enabled_index = 1:nEnabled_gammas
    enabled_meta = bank.metas(enabled_index);
    max_sibling_gamma = enabled_meta.max_sibling_gamma;
    nUnmasked_indices = find(sibling_gammas<=max_sibling_gamma,1,'last');
    log2_resolution = enabled_meta.log2_resolution;
    unbounded_log2_sampling = log2_resolution + log2_oversampling;
    log2_sampling = min(unbounded_log2_sampling,log2_factor);
    bank.metas(enabled_index).log2_sampling = log2_sampling;
    log2_resamplings{enabled_index} = ...
        log2_sampling - sibling_log2_samplings(1:nUnmasked_indices);
end
bank.log2_resamplings = log2_resamplings;
bank.psis = bank.psis{1}([bank.metas.gamma]);
bank.sibling.subscript = sibling.subscripts;
end
