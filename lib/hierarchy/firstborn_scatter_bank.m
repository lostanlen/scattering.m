function bank = firstborn_scatter_bank(bank,uncle)
%%
sibling = [];
if nargin<2
    uncle = [];
end
bank.metas = get_enabled_metas(bank.metas,bank.behavior,sibling,uncle);
nEnabled_gammas = length(bank.metas);
if ~bank.behavior.has_mr_output
    % This would be useful for fast, uniformly sampled scalogram visualization
    error('Zero-level gammas not ready yet');
else
    log2_oversampling = bank.behavior.U.log2_oversampling;
    bank.log2_resamplings = ...
        min(log2_oversampling + [bank.metas.log2_resolution].', 0);
    for gamma_index = 1:nEnabled_gammas
        bank.metas(gamma_index).log2_sampling = ...
            bank.log2_resamplings(gamma_index);
    end
end
bank.psis = bank.psis{1}([bank.metas.gamma],:);
end