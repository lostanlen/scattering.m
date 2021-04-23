function [total_norm, layer_norms] = sc_norm(S, spatial_subscripts, layers)
nLayers = length(S);
if nargin<3
    layers = (1:nLayers);
end
if nargin<2
    spatial_subscripts = 1;
end

[formatted_S, formatted_layers] = sc_format(S, spatial_subscripts, layers);

layer_norms = zeros(1, nLayers);
for layer_id = 1:nLayers
    layer_norms(layer_id) = sum(abs(formatted_layers{layer_id}(:))) * ...
        2^(1-layer_id);
end

total_norm = sum(layer_norms);
end