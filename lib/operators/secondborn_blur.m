function data = secondborn_blur(data_ft,bank,sibling_level_counter)
% TODO: map explicitly along cells if sibling_level_counter>0
% This is needed for blurring along gamma
if sibling_level_counter>0
    error('secondborn_scatter with sibling_level_counter>0 not ready yet');
end

%%
log2_resamplings = bank.log2_resamplings;
nSibling_gammas = length(log2_resamplings);
subscripts = bank.behavior.subscripts;
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
data = cell([nCousins,1]);
phi= bank.phi;
ref_colons = bank.behavior.colons;
first_input_sizes = drop_trailing(size(data_ft{1}));
nInput_dimensions = length(first_input_sizes);
asgn_colons.type = '()';
asgn_colons.subs = replicate_colon(nInput_dimensions+1);
tensor_sizes = [first_input_sizes, NaN];
tensor_sizes(subscripts) = ...
    first_input_sizes(subscripts) * pow2(log2_resamplings(1));
if is_sibling_padded
    tensor_sizes(end) = pow2(nextpow2(nSibling_gammas + ...
        bank.behavior.gamma_padding_length));
else
    tensor_sizes(end) = nSibling_gammas;
end
local_subsasgn_structure = asgn_colons;
local_tensor = zeros(tensor_sizes);
% This loop can be parallelized
for cousin_index = 1:nCousins
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        local_data_ft = data_ft{sibling_index,cousin_index};
        local_subsasgn_structure.subs{end} = sibling_index;
        local_tensor = subsasgn(local_tensor, ...
            local_subsasgn_structure, ...
            ifft_multiply(local_data_ft,phi, ...
            log2_resampling,ref_colons,subscripts));
    end
    data{cousin_index} = local_tensor;
end
if nCousins>1
    data = reshape(data,[data_ft_sizes,1]);
elseif sibling_level_counter==0
    data = data{1};
end
end
