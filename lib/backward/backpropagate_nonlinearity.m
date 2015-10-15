function layer_dY_end = ...
    backpropagate_nonlinearity(nonlinearity,layer_dU,layer_Y_end,layer_U)
%% Deep map across cells
if iscell(layer_dU)
    nCells = numel(layer_dU);
    layer_dY_end = cell(size(layer_dU));
    for cell_index = 1:nCells
        if ~isempty(layer_dU{cell_index})
            layer_dY_end{cell_index} = backpropagate_nonlinearity( ...
                nonlinearity,layer_dU{cell_index},layer_Y_end{cell_index}, ...
                layer_U{cell_index});
        end
    end
    return
end

if nonlinearity.is_modulus
    layer_dY_end.data = dU_times_reY_over_U( ...
        layer_dU.data,layer_Y_end.data,layer_U.data, ...
        layer_dU.ranges,layer_Y_end.ranges);
elseif nonlinearity.is_uniform_log
    layer_dY_end.data = cell(size(layer_Y_end.data));
    for cell_index = 1:numel(layer_Y_end.data)
        nSamples = size(layer_U.data{cell_index}, 1);
        layer_dY_end.data{cell_index} = ...
            layer_dU.data{cell_index} ./ ...
            (nonlinearity.denominator + nSamples*layer_U.data{cell_index}) .* ...
            layer_Y_end.data{cell_index} ./ ...
            (eps() + layer_U.data{cell_index});
    end
end

%% Copy metadata
layer_dY_end = copy_metadata(layer_Y_end,layer_dY_end);
end
