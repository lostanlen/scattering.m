function [S, U, Y] = sc_propagate(signal, archs)
%% Initialization of networks S, U, and Y.
% S and U are zero-based ; Y is one-based.
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1, nLayers);
Y = cell(1, nLayers);

U{1+0} = initialize_U(signal, archs{1}.banks{1});

%% Propagation cascade
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    if isfield(arch, 'banks')
        Y{layer} = U_to_Y(U{1 + previous_layer}, arch.banks);
    else
        Y{layer} = U{1 + previous_layer};
    end
    if isfield(arch, 'nonlinearity')
        % Apply non-linearity to last sub-layer Y to get layer U
        U{1+layer} = Y_to_U(Y{layer}{end}, arch.nonlinearity);
    end
    
    % Blur/pool first sub-layer Y to get layer S
    if isfield(arch, 'invariants')
        S{1+previous_layer} = Y_to_S(Y{layer}, arch);
    end
end

%% Unchunk if necessary
S = sc_unchunk(S);

end
