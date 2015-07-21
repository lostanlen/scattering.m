function unchunked_layer = unchunk_layer(layer)
if iscell(layer)
    nCells = numel(layer);
    unchunked_layer = cell(size(layer));
    for cell_index = 1:nCells
        layer_cell = layer{cell_index};
        if isempty(layer_cell)
            continue
        end
        unchunked_layer{cell_index} = unchunk_layer(layer_cell);
    end
else
    unchunked_layer = layer;
    chunk_key.chunk = cell(1,1);
    chunk_variable = get_leaf(layer.variable_tree,chunk_key);
    if isempty(chunk_variable)
        return
    end
    chunk_subscript = chunk_variable.subscripts;
    unchunked_layer.data = unchunk_data(layer.data,chunk_subscript);
    unchunked_layer.ranges{1+0} = ...
        unchunk_ranges(layer.ranges{1+0},chunk_subscript);
end
