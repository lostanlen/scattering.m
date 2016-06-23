function [formatted_S,formatted_layers] = sc_format(S, spatial_subscripts, layers)
nLayers = length(S);
if nargin<3
    layers = (2:nLayers);
end
if nargin<2
    spatial_subscripts = 1;
end

formatted_layers = cell(length(layers),1);
for layer_index = layers
    formatted_layers{layer_index} = ...
        format_layer(S{layer_index}, spatial_subscripts);
end

formatted_S = [formatted_layers{:}].';
end
