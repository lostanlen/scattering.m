function layer_dY = ...
    backpropagate_layer(layer_dS,layer_dU,layer_Y,layer_U,arch)
%% Initialization
banks = arch.banks;
nonlinearity = arch.nonlinearity;
nVariables_to_transform = length(banks);
layer_dY = cell(1+nVariables_to_transform, 1);

%% Backpropagation of nonlinearity in dU
layer_dY{end} = ...
    backpropagate_nonlinearity(nonlinearity, layer_dU, layer_Y{end}, layer_U);

%% Multi-variable case: iterated one-variable backpropagation
if nVariables_to_transform>1
    for variable_index = nVariables_to_transform:-1:2
        bank = banks{variable_index};
        suffix_name = get_suffix(bank.behavior.key);
        is_unspiraled = strcmp(suffix_name,'j');
        sub_dY = layer_dY{1+variable_index};
        nCells = 3^(variable_index-1);
        previous_sub_dY = cell(nCells,1);
        for cell_index = 1:nCells
            if isempty(sub_dY{cell_index})
                continue
            end
            cell_dY = dual_blur_dY(sub_dY{nCells+cell_index}, bank);
            cell_dY = ...
                copy_metadata(layer_Y{variable_index}{cell_index}, cell_dY);
            if is_unspiraled
                cell_dY = unspiral_metadata(cell_dY);
            end
            cell_dY = dual_scatter_dY(sub_dY{cell_index}, bank, cell_dY);
            previous_sub_dY{cell_index} = cell_dY;
        end
        routing_sizes = [repmat(3,1,variable_index-1), 1];
        layer_dY{variable_index} = reshape(previous_sub_dY, routing_sizes);
    end
    layer_dY{1+1} = layer_dY{1+1}{1};
    layer_Y{1+0} = layer_Y{1+0}{1};
end

%% Backpropagation of blurring/pooling operator in dS
layer_dY{1+0} = dS_backto_dY(layer_dS, arch);
layer_dY{1+0} = copy_metadata(layer_Y{1+0}, layer_dY{1+0});

%% Backpropagation of first variable
layer_dY{1+0} = dual_scatter_dY(layer_dY{1+1}, banks{1}, layer_dY{1+0});
end