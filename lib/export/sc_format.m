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

%% Unpadding of spatial variable
unpadded_length = S{1+0}.variable_tree.time{1}.leaf.unpadded_size;
hop_length = S{1+0}.ranges{1}(2,1);
nSamples = ceil(unpadded_length / hop_length);
formatted_S = formatted_S(:,1:nSamples);
end