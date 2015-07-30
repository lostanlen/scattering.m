function [formatted_layer, hashes] = format_layer(layer_S, spatial_subscripts)
if iscell(layer_S)
    nCells = numel(layer_S);
    formatted_cells = cell(nCells,1);
    hashed_cells = cell(nCells,1);
    hash_accumulator = 0;
    for cell_index = 1:nCells
        cell_S = layer_S{cell_index};
        if ~isempty(cell_S)
            [formatted_cells{cell_index}, hashed_cell] = ...
                format_layer(cell_S, spatial_subscripts);
            hashed_cell = hashed_cell + hash_accumulator;
            hashed_cells{cell_index} = hashed_cell;
            hash_accumulator = hash_accumulator + numel(hashed_cell);
        end
    end
    formatted_layer = [formatted_cells{:}];
    hashes = [hashed_cells{:}];
    return
end

[formatted_layer,hashes] = ...
    format_data(layer_S.data, spatial_subscripts, layer_S.ranges{1+0});
end