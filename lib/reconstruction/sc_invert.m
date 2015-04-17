function layer_Y_out = sc_invert(layer_Y_in,layer_S,arch)
%% Initialization
banks = arch.banks;
nVariables_to_transform = length(banks);
layer_Y_out = cell(1+nVariables_to_transform,1);
layer_Y_out{end} = layer_Y_in{end};

%% Multi-variable case: iterated one-variable inversion
if nVariables_to_transform>1
    for variable_index = nVariables_to_transform:-1:2
        bank = banks{variable_index};
        sub_Y = layer_Y_out{1+variable_index};
        nCells = 3^(variable_index-1);
        previous_sub_dY = cell(nCells,1);
        for cell_index = 1:nCells
            if isempty(sub_Y{cell_index})
                continue
            end
            cell_Y = dual_blur_dY(sub_Y{nCells+cell_index},bank);
            cell_Y = ...
                copy_metadata(layer_Y_in{variable_index}{cell_index},cell_Y);
            cell_Y = dual_scatter_dY(sub_Y{cell_index},bank,cell_Y);
            previous_sub_dY{cell_index} = cell_Y;
        end
        routing_sizes = [repmat(3,1,variable_index-1),1];
        layer_Y_out{variable_index} = reshape(previous_sub_dY,routing_sizes);
    end
    layer_Y_out{1+1} = layer_Y_out{1+1}{1};
    layer_Y_out{1+0} = layer_Y_out{1+0}{1};
end

%% Inversion of blurring operator in dS
layer_Y_out{1+0} = dS_backto_dY(layer_S,arch);

%% Inversion of first-variable scattering operator
layer_Y_out{1+0} = copy_metadata(layer_Y_in{1+0},layer_Y_out{1+0});
layer_Y_out{1+0} = dual_scatter_dY(layer_Y_in{1+1},banks{1},layer_Y_out{1+0});
end

