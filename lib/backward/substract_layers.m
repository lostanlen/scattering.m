function layer_S_minuend = substract_layers(layer_S_minuend,layer_S_subtrahend)
if iscell(layer_S_minuend)
    %% Substraction along cells (recursive call)
    if isempty(layer_S_minuend)
        return;
    end
    nCells = prod(drop_trailing(size(layer_S_minuend)));
    for cell_index = 1:nCells
        layer_S_minuend{cell_index} = substract_layers( ...
            layer_S_minuend{cell_index},layer_S_subtrahend{cell_index});
    end
else
    %%
    layer_S_minuend.data = map_substract(layer_S_minuend,layer_S_subtrahend);
end
end