function S = reduce_minibatch(S_batches)
%% Loop across layers.
nLayers = length(S_batches{1});
S = cell(1, nLayers);

for layer_id = 0:(nLayers-1)
    %% Reduce minibatch of layer.
    S{1+layer_id} = ...
        reduce_minibatch_layer(cellfun(@(x) x(1+layer_id), S_batches, ...
            'UniformOutput', false));
end

end

