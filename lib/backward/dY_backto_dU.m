function layer_dU = dY_backto_dU(layer_dY1)
%% Deep map across cells
if iscell(layer_dY1)
    layer_dU = map_unary(@dY_backto_dU,layer_dY1);
    return
end

%% Take real part of data
layer_dU.data = map_unary(@real,layer_dY1.data);

%% Copy metadata
layer_dU.keys = layer_dY1.keys;
layer_dU.ranges = layer_dY1.ranges;
layer_dU.variable_tree = layer_dY1.variable_tree;
end