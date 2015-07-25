function psis = permute_subscript(psis, subscript)
%% Deep map across cells
if iscell(psis)
    for cell_index = 1:numel(psis)
        if ~isempty(psis{cell_index})
            psis{cell_index} = permute_subscript(psis{cell_index}, subscript);
        end
    end
    return
end

%% Compute permutation
old_subscript = length(drop_trailing(size(psis(1).ft)));
permutation = 1:subscript;
permutation(old_subscript) = subscript;
permutation(subscript) = old_subscript;

%%
nLambdas = numel(psis);
for lambda = 1:nLambdas
    psis(lambda).ft = permute(psis(lambda).ft,permutation);
end
end

