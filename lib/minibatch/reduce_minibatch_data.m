function S_data = reduce_minibatch_data(S_data_batches, chunk_subscript)
%% Recursive reduction across cells
if iscell(S_data_batches{1})
    sizes = size(S_data_batches{1});
    S_data = cell(sizes);
    nCells = prod(sizes);
    for cell_index = 1:nCells
        S_data{cell_index} = reduce_minibatch_data( ...
            cellfun(@(x) x{cell_index}, S_data_batches, ...
            'UniformOutput', false), ...
            chunk_subscript);
    end
    return
end
%%

S_data = cat(chunk_subscript, S_data_batches{:});
end

