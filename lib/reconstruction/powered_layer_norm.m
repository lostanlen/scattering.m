function powered_ellp_norm = powered_layer_norm(layer_S,norm_handle)
%% Deep map across cells
if iscell(layer_S)
    powered_ellp_norm = 0;
    for cell_index = 1:numel(layer_S)
        if ~isempty(layer_S{cell_index})
            powered_ellp_norm = powered_ellp_norm + ...
                powered_layer_norm(layer_S{cell_index},norm_handle);
        end
    end
    return
end

%% Call map reduce to sum powered norms of all paths
powered_ellp_norm = mapreduce_unary(norm_handle,layer_S.data);
end