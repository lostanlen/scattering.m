function layer_Y = U_to_Y(layer_U,arch)
%% Initialization
banks = arch.banks;
nVariables_to_transform = length(banks);
layer_Y = cell(1+nVariables_to_transform,1);

%% Special case of single-variable scattering
is_U_single_scattered = nVariables_to_transform==1 && ...
    banks{1}.behavior.U.is_scattered && ...
    ~banks{1}.behavior.U.is_blurred && ...
    ~banks{1}.behavior.U.is_bypassed;
if is_U_single_scattered
    layer_Y{1+0} = initialize_Y(layer_U,banks);
    layer_Y{1+0} = perform_ft(layer_Y{1+0},banks{1}.behavior.key);
    layer_Y{1+1} = scatter_Y(layer_Y{1+0},banks{1});
    return;
end

%% Iterated one-variable scattering, blurring and bypassing
layer_Y{1+0} = {initialize_Y(layer_U,banks)};
for variable_index = 1:nVariables_to_transform
    bank = banks{variable_index};
    is_scattered = bank.behavior.U.is_scattered;
    is_blurred = bank.behavior.U.is_blurred;
    if is_scattered || is_blurred
        key = bank.behavior.key;
        layer_Y{variable_index} = perform_ft(layer_Y{variable_index},key);
    end
    sub_Y = layer_Y{variable_index};
    nCells = 3^(variable_index-1);
    next_sub_Y = cell(3*nCells,1);
    for cell_index = 1:nCells
        cell_Y = sub_Y{cell_index};
        if isempty(cell_Y)
            continue;
        end
        if is_scattered
            next_sub_Y{cell_index} = scatter_Y(cell_Y,bank);
        end
        if is_blurred
            next_sub_Y{nCells+cell_index} = blur_Y(cell_Y,bank);
        end
        if bank.behavior.U.is_bypassed
            next_sub_Y{2*nCells+cell_index} = cell_Y;
        end
    end
    if variable_index==1
        layer_Y{1+variable_index} = next_sub_Y;
    else
        routing_sizes = repmat(3,1,variable_index);
        layer_Y{1+variable_index} = reshape(next_sub_Y,routing_sizes);
    end
end
end
