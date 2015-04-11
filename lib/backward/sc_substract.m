function dS = sc_substract(S_minuend,S_subtrahend)
%% Initialization
nLayers = length(S_minuend);
dS = cell(1,nLayers);

%% Loop over layers
for layer_index = 0:nLayers-1
    %% Pairwise substraction of minuend and subtrahend layers
    layer_S_minuend = S_minuend{1+layer_index};
    layer_S_subtrahend = S_subtrahend{1+layer_index};
    dS{1+layer_index} = substract_layer(layer_S_minuend,layer_S_subtrahend);
end
end