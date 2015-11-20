function data_out = map_maxpool(data_in, subscripts)
%% Cell-wise map
if iscell(data_in)
    sizes = size(data_in);
    data_out = cell(sizes);
    nCells = prod(sizes);
    for cell_index = 1:nCells
        data_out{cell_index} = map_maxpool(data_in{cell_index}, subscripts);
    end
    return
end

%% Tail call
nSubscripts = length(subscripts);
data_out = data_in;

for subscript_index = 1:nSubscripts
    subscript = subscripts(subscript_index);
    data_out = max(data_out, [], subscript) * size(data_out, subscript);
end