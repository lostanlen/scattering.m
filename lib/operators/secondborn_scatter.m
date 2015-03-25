function data = secondborn_scatter(data_ft,bank,sibling_level_counter)
% TODO: map explicitly along cells if sibling_level_counter>0
if sibling_level_counter>0
    error('secondborn_scatter with sibling_level_counter>0 not ready yet');
end

%% Data structure initialization
log2_resamplings = bank.log2_resamplings;
nEnabled_gammas = length(log2_resamplings);

%%
first_input_sizes = drop_trailing(size(data_ft{1}));
tensor_sizes = [first_input_sizes,2,bank.spec.nThetas];
nInput_dimensions = length(first_input_sizes);
downgraded_sibling_subscript = nInput_dimensions + 1;
subscripts = bank.behavior.subscripts;
signal_sizes = bank.spec.size;
log2_samplings = [bank.metas.log2_sampling];
is_sibling_padded = isfield(bank.behavior,'gamma_padding_length');
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
data = cell(nEnabled_gammas,nCousins);
psis = bank.psis;
ref_colons = bank.behavior.colons;
asgn_colons.type = '()';

%%
if bank.spec.nThetas==1
    asgn_colons.subs = replicate_colon(nInput_dimensions+1);
    data_slice = cell(1,nCousins);
    % This loop can be parallelized
    for gamma_index = 1:nEnabled_gammas
        local_log2_resamplings = log2_resamplings{gamma_index};
        nSibling_gammas = length(local_log2_resamplings);
        log2_sampling = log2_samplings(gamma_index);
        local_tensor_sizes = tensor_sizes;
        local_tensor_sizes(subscripts) = signal_sizes * pow2(log2_sampling);
        if is_sibling_padded
            local_tensor_sizes(downgraded_sibling_subscript) = ...
                pow2(nextpow2(nSibling_gammas+ ...
                bank.behavior.gamma_padding_length));
        else
            local_tensor_sizes(downgraded_sibling_subscript) = ...
                nSibling_gammas;
        end
        local_tensor = zeros(local_tensor_sizes);
        local_psis = psis(gamma_index);
        local_subsasgn_structure = asgn_colons;
        local_data_slice = data_slice;
        for cousin_index = 1:nCousins
            for sibling_index = 1:nSibling_gammas
                log2_resampling = local_log2_resamplings(sibling_index);
                local_data_ft = data_ft{sibling_index,cousin_index};
                local_subsasgn_structure.subs{downgraded_sibling_subscript} = ...
                    sibling_index;
                local_tensor = subsasgn(local_tensor,local_subsasgn_structure, ...
                    ifft_multiply(local_data_ft,local_psis, ...
                    log2_resampling,ref_colons,subscripts));
            end
            local_data_slice{cousin_index} = local_tensor;
        end
        data(gamma_index,:) = local_data_slice;
    end
else
    asgn_colons.subs = replicate_colon(nInput_dimensions+2);
    % TODO: write loops when nThetas>1 with inlined map_gamma
end
%%
if nCousins>1
    data = reshape(data,[nEnabled_gammas, cousin_sizes]);
    if sibling_subscript>1
        inverse_permutation(permuted_subscripts) = 1:nData_dimensions;
        data = permute(data,inverse_permutation);
    end
end
end
