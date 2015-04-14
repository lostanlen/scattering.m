function layer_dY_end = ...
    backpropagate_nonlinearity(nonlinearity,layer_dU,layer_Y_end,layer_U)
if ~nonlinearity.is_modulus
    error('Backpropagation only available for modulus nonlinearity');
end

%% Call dU_times_Y_over_U to perform the backpropagation
dU_data_ft = layer_dU.data_ft;
Y_data_ft = layer_Y_end.data_ft;
U_data_ft = layer_U.data_ft;
layer_dY_end.data = ...
    dU_times_Y_over_U(dU_data_ft,Y_data_ft,U_data_ft,dU_ranges,Y_ranges);

%% Update other fields
layer_dY_end.keys = layer_dU.keys;
layer_dY_end.ranges = layer_dU.ranges;
layer_dY_end.variable_tree = layer_dU.variable_tree;

end