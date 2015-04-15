function layer_dU = dY_backto_dU(layer_dY1)
%% Deep map across cells
if iscell(layer_dY1)
    layer_dU = map_unary(@dY_backto_dU,layer_dY1);
    return
end

%% Take real part of data
layer_dU.data = map_unary(@real,layer_dY1.data);
end