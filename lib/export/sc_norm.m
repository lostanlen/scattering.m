function [total_norm, layer_norms] = sc_norm(S, spatial_subscripts, layers)
nLayers = length(S);
if nargin<3
    layers = (1:nLayers);
end
if nargin<2
    spatial_subscripts = 1;
end

[formatted_S, formatted_layers] = sc_format(S, spatial_subscripts, layers);
nSamples = size(formatted_S, 2);

layer_norms = zeros(1, nLayers);
layer_norms(1+0) = 0.5 * norm(S{1+0}.data);% / sqrt(nSamples);
for layer_id = 2:nLayers
    l2_norm = sqrt(sum(formatted_layers{layer_id}.^2, 2)) / sqrt(nSamples);
    %l2_norm = sum(formatted_layers{layer_id}, 2) / sqrt(nSamples);
    layer_norms(layer_id) = sum(l2_norm) * 2^(1-layer_id);
end

total_norm = sum(layer_norms);
end