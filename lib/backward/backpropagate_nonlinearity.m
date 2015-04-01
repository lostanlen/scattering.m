function layer_dY_end = ...
    backpropagate_nonlinearity(nonlinearity,layer_dU,layer_Y_end,layer_U)
if ~nonlinearity.is_modulus
    error('Backpropagation only available for modulus nonlinearity');
end
layer_dY_end = layer_dU;
end