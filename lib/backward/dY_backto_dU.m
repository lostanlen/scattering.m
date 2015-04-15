function layer_dU = dY_backto_dU(layer_dY)
%% Deep map across cells
if iscell(layer_dY)
    layer_dU = map_unary(@dY_backto_dU,layer_dY);
    return
end

%% Take real part of data
layer_dU.data = map_unary(@real,layer_dY.data);
end