function data = sibling_blur(data_ft,bank,sibling_level_counter)
%% Deep dispatch across levels
if sibling_level_counter>0
    next_sibling_level_counter = sibling_level_counter - 1;
    data_sizes = size(data_ft);
    nCells = prod(data_sizes);
    vectorized_output = cell(1,nCells);
    for cell_index = 1:nCells
        vectorized_output{cell_index} = ...
            sibling_blur(data_ft{cell_index},bank,sibling, ...
            next_sibling_level_counter);
    end
    data_ft = reshape(vectorized_output,data_sizes);
    return;
end

%% Definition of resampling factors
log2_resamplings = bank.log2_resamplings;
nSibling_gammas = length(log2_resamplings);
bank_behavior = bank.behavior;
data_ft_sizes = drop_trailing(size(data_ft));
nData_dimensions = length(data_ft_sizes);
sibling_subscript = bank.sibling.subscript;
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=sibling_subscript);
    cousin_sizes = data_ft_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if sibling_subscript>1
        permuted_subscripts = [sibling_subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    nSibling_gammas = data_ft_sizes(sibling_subscript);
    data_ft = reshape(data_ft,[nSibling_gammas,nCousins]);
else
    nCousins = 1;
end
data = cell([nSibling_gammas,nCousins]);
phi= bank.phi;
%%
% This loop can be parallelized
for cousin_index = 1:nCousins
    data_slice = cell(nSibling_gammas,1);
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        local_data_ft = data_ft{sibling_index,cousin_index};
        data_slice{sibling_index} = map_filter(local_data_ft,phi, ...
            log2_resampling,bank_behavior);
    end
    data(:,cousin_index) = data_slice;
end
if nCousins>1
    data = reshape(data,[data_ft_sizes,1]);
end
end
