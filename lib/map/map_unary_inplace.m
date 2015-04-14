function data_out = map_unary_inplace(inplace_handle,data_in,data_out)
if iscell(data_in)
    %% Handle map along cells (recursive call)
    if isempty(data_in)
        return
    end
    nCells = numel(data_in);
    if iscell(data_in{1})
        for cell_index = 1:nCells
            data_out{cell_index} = map_unary_inplace(inplace_handle, ...
                data_in{cell_index},data_out{cell_index});
        end
    else
        for cell_index = 1:nCells
            data_cell = data_in{cell_index};
            if isempty(data_cell)
                data_out{cell_index} = [];
            else
                data_out{cell_index} = ...
                    inplace_handle(data_cell,data_out{cell_index});
            end
        end
    end
else
    %% Tensor handle
    if ~isempty(data_in)
        data_out = inplace_handle(data_in,data_out);
    else
        data_out = [];
    end
end
end
