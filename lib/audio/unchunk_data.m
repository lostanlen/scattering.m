function unchunked_data = unchunk_data(data,chunk_subscript)
%% Deep map across cells
if iscell(data)
    nCells = numel(data);
    unchunked_data = cell(size(data));
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        if isempty(data_cell)
            continue
        end
        unchunked_data{cell_index} = unchunk_data(data_cell,chunk_subscript);
    end
%% Data unchunking
else
    data_size = size(data);
    unchunked_size = ...
        [data_size(1:(chunk_subscript-2)), ...
        data_size(chunk_subscript-1) * data_size(chunk_subscript), ...
        data_size((chunk_subscript+1):end)];
    unchunked_data = reshape(data,unchunked_size);
end
end

