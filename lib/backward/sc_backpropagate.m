function [dsignal,dS,dU,dY] = sc_backpropagate(target_S,S,U,Y,archs)
%% Pointwise substraction
dS = sc_substract(target_S,S);

%% Initialization of dU and dY
nLayers = length(archs);
dU = cell(1,1+nLayers);
dY = cell(1,1+nLayers);

%% Backpropagation of last layer
dY{end} = dS_backto_dY(dS{end},archs{end});
dU{end} = dY{end}{1};
dU{end} = copy_metadata(U{end},dU{end});

%% Backpropagation cascade
for layer = nLayers:-1:1
    arch = archs{layer};
    layer_Y = Y{layer};
    layer_U = U{1+layer};
    layer_dU = dU{1+layer};
    previous_layer = layer - 1;
    layer_dS = dS{1+previous_layer};
    dY{layer} = backpropagate_layer(layer_dS,layer_dU,layer_Y,layer_U,arch);
    dU{1+previous_layer} = dY_backto_dU(dY{layer});
end

%% Return difference in signal domain
dsignal = dU{1+0}.data;
end