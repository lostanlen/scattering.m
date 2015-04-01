function data = map_unary(unary_handle,data)
if iscell(data)
    %% Handle map along cells (recursive call)
    if isempty(data)
        return;
    end
    nCells = numel(data);
    if iscell(data{1})
        for cell_index = 1:nCells
            data{cell_index} = ...
                map_unary(unary_handle,data{cell_index});
        end
    else
        for cell_index = 1:nCells
            data_cell = data{cell_index};
            if isempty(data_cell)
                data{cell_index} = [];
            else
                data{cell_index} = unary_handle(data_cell);
            end
        end
    end
else
    %% Tensor handle
    if ~isempty(data)
        data = unary_handle(data);
    else
        data = [];
    end
end
end
