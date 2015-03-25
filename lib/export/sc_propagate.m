function [S,U,Y] = propagate(signal,archs)
%% Initialization of networks S, U and Y.
% S and U are zero-based ; Y is one-based.
nLayers = length(archs);
S = cell(1,1+nLayers);
U = cell(1,1+nLayers);
Y = cell(1,1+nLayers);

U{1+0} = initialize_U(signal);

%% Propagation cascade
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y 
    Y{layer} = U_to_Y(U{1+previous_layer},arch);
    % Apply non-linearity to last sub-layer Y to get layer U
    U{1+layer} = Y_to_U(Y{layer}{end},arch);
    % Blur/pool first sub-layer Y to get layer S
    S{1+previous_layer} = Y_to_S(Y{layer},arch);
end

%% Use last bank to compute last layer S
% Note that the last banks are used to compute penultimate layer S
% (see loop above) as well as last layer S.
Y{1+nLayers}{1+0} = initialize_Y(U{1+nLayers},arch.banks);S{1+nLayers} = Y_to_S(Y{1+nLayers},arch);
end
