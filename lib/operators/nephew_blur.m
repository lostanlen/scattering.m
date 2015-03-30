function data = ...
    nephew_blur(data_ft,bank,sibling,uncle,uncle_level_counter)
if uncle_level_counter>0
    % TODO: map explicitly
    return;
end

%%
% TODO: write generic code that finds level_counter
level_counter = 0;
data_ft_sizes = drop_trailing(size(data_ft),1);
uncle_subscript = uncle.subscripts;
nUncle_gammas = data_ft_sizes(uncle_subscript);
nData_dimensions = length(data_ft_sizes);
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=uncle_subscript);
    cousin_sizes = data_ft_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if uncle.subscripts(1)>1
        permuted_subscripts = [uncle_subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    data_ft = transpose(reshape(data_ft,[nUncle_gammas,nCousins]));
else
    nCousins = 1;
end
data = cell(nUncle_gammas,nCousins);

suffix_name = get_suffix(bank.behavior.key);
switch suffix_name
    case 'gamma'
        log2_supports = ...
            nextpow2(bank.spec.T/2 + [uncle.metas.max_sibling_gamma]);
    case 'j'
        log2_supports = ...
            nextpow2(bank.spec.T/2 + [uncle.metas.max_sibling_j]);
end
support_indices = log2(bank.spec.size) - log2_supports + 1;

%%
% Caution: lowest values of uncle_index may bring empty banks if their
% max_sibling_gammas is below the bank.metas.scale(1);
for uncle_index = 1:nUncle_gammas
    nephew_bank = bank;
    nephew_bank.phi = bank.phi(support_indices(uncle_index));
    if isempty(sibling)
        nephew_bank = firstborn_blur_bank(nephew_bank);
        if nData_dimensions==1
            data{uncle_index} = ...
                firstborn_blur(data_ft{uncle_index}, ...
                nephew_bank,level_counter);
        else
            data{uncle_index} = ...
                firstborn_blur(data_ft(uncle_index,:), ...
                nephew_bank,level_counter);
        end
    else
        % This is needed e.g. for second-order blurring along gamma
        error('sibling scattering not ready yet in nephew_blur')
    end
end
end
