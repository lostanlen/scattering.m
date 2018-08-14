function S_layer = reduce_minibatch_layer(S_layer_batches)
%% Recursive reduction across cells
if iscell(S_layer_batches{1})
    sizes = size(S_layer_batches{1});
    S_layer = cell(sizes);
    nCells = prod(sizes);
    for cell_index = 1:nCells
        if ~isempty(S_layer_batches{1}{cell_index})
            S_layer{cell_index} = reduce_minibatch_layer( ...
                cellfun(@(x) x{cell_index}, S_layer_batches, ...
                'UniformOutput', false));
        end
    end
    return
end

%% Tail call
S_layer = S_layer_batches{1};

nBatches = length(S_layer_batches);
if nBatches > 1
    chunk_subscript = ...
        S_layer_batches{1}.variable_tree.chunk{1}.leaf.subscripts;
    
    S_layer.data = reduce_minibatch_data( ...
        cellfun(@(x) x.data, S_layer_batches, 'UniformOutput', false), ...
        chunk_subscript); 
end

end
