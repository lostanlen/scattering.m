function formatted_layer = format_layer(layer_S, spatial_subscripts)
if iscell(layer_S)
    nCells = numel(layer_S);
    formatted_cells = cell(nCells,1);
    for cell_index = 1:nCells
        cell_S = layer_S{cell_index};
        if ~isempty(cell_S)
            formatted_cells{cell_index} = ...
                format_layer(cell_S, spatial_subscripts);
        end
    end
    formatted_layer = [formatted_cells{:}];
    return
end

formatted_layer = ...
    format_data(layer_S.data, spatial_subscripts, layer_S.ranges{1+0});
end