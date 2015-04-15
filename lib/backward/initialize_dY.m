function layer_dY = initialize_dY(layer_Y)
%% Cell-wise map
if iscell(layer_U)
    initialization_handle = @(x) initialize_Y(x,layer_banks);
    layer_Y1 = map_unary(initialization_handle,layer_U);
    return;
end

%%

end