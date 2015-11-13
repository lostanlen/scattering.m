function data_out = map_sum(data_in, subscripts)
%% Cell-wise map
if iscell(data_in)
    sizes = size(data_in);
    data_out = cell(sizes);
    nCells = prod(sizes);
    for cell_index = 1:nCells
        data_out{cell_index} = map_sum(data_in{cell_index}, subscripts);
    end
    return
end

%% Tail call
data_out = sum(data_in, subscripts);