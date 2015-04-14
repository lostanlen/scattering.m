function layer_dS = substract_layer(layer_minuend,layer_subtrahend)
if iscell(layer_minuend)
    nCells = numel(layer_minuend);
    layer_dS = cell(size(layer_minuend));
    for cell_index = 1:nCells
        minuend_cell = layer_minuend{cell_index};
        if isempty(minuend_cell)
            continue
        end
        subtrahend_cell = layer_subtrahend{cell_index};
        if isempty(subtrahend_cell)
            continue
        end
        layer_dS{cell_index} = substract_layer(minuend_cell,subtrahend_cell);
    end
else
    layer_dS = layer_minuend;
    [layer_dS.data,layer_dS.ranges] = substract_data( ...
        layer_minuend.data,layer_subtrahend.data, ...
        layer_minuend.ranges,layer_subtrahend.ranges);
end