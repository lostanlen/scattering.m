function layer_dY_end = ...
    backpropagate_nonlinearity(nonlinearity,layer_dU,layer_Y_end,layer_U)
%% Deep map across cells
if iscell(layer_dU)
    nCells = numel(layer_dU);
    layer_dY_end = cell(size(layer_dU));
    for cell_index = 1:nCells
        layer_dY_end{cell_index} = ...
            backpropagate_nonlinearity(nonlinearity, ...
            layer_dU{cell_index},layer_dY_end{cell_index},layer_U{cell_index});
    end
    return
end

%% Error if nonlinearity is not modulus
if ~nonlinearity.is_modulus
    error('Backpropagation only available for modulus nonlinearity');
end

%% Call dU_times_Y_over_U to perform the backpropagation
layer_dY_end.data = dU_times_Y_over_U( ...
    layer_dU.data,layer_Y_end.data,layer_U.data, ...
    layer_dU.ranges,layer_Y_end.ranges);

%% Copy metadata
layer_dY_end = copy_metadata(layer_Y_end,layer_dY_end);
end