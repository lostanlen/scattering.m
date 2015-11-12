function layer_Y = U_to_Y(layer_U,arch)
%% Initialization
banks = arch.banks;
nBanks = length(banks);
layer_Y = cell(1+nBanks,1);

%% Special case of single-variable scattering
is_U_single_scattered = nBanks==1 && ...
    banks{1}.behavior.U.is_scattered && ...
    ~banks{1}.behavior.U.is_blurred && ...
    ~banks{1}.behavior.U.is_bypassed;
if is_U_single_scattered
    layer_Y{1+0} = initialize_Y(layer_U,banks);
    layer_Y{1+0} = perform_ft(layer_Y{1+0},banks{1}.behavior.key);
    layer_Y{1+1} = scatter_Y(layer_Y{1+0},banks{1});
    return
end

%% Iterated one-variable scattering, blurring and bypassing
layer_Y{1+0} = {initialize_Y(layer_U,banks)};
for variable_index = 1:nBanks
    % Fourier transform
    bank = banks{variable_index};
    is_scattered = bank.behavior.U.is_scattered;
    is_blurred = bank.behavior.U.is_blurred;
    if is_scattered || is_blurred
        key = bank.behavior.key;
        layer_Y{variable_index} = perform_ft(layer_Y{variable_index},key);
    end
    
    % Initialization of next container
    sub_Y = layer_Y{variable_index};
    nCells = 3^(variable_index-1);
    next_sub_Y = cell(3*nCells,1);
    
    for cell_index = 1:nCells
        cell_Y = sub_Y{cell_index};
        if isempty(cell_Y)
            continue
        end
        % Scattering: application of band-pass filters (psis)
        if is_scattered
            next_sub_Y{cell_index} = scatter_Y(cell_Y,bank);
        end
        % Blurring: application of low-pass filter (phi)
        if is_blurred
            next_sub_Y{nCells+cell_index} = blur_Y(cell_Y,bank);
        end
        % Bypasssing: does nothing
        if bank.behavior.U.is_bypassed
            next_sub_Y{2*nCells+cell_index} = cell_Y;
        end
    end
    
    % Output allocation, reshaping in 3x3x3 format if needed
    if variable_index==1
        layer_Y{1+variable_index} = next_sub_Y;
    else
        routing_sizes = repmat(3,1,variable_index);
        layer_Y{1+variable_index} = reshape(next_sub_Y,routing_sizes);
    end
end
end