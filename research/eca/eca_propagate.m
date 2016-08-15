function [S, U, Y] = eca_propagate(batch, archs)
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1,nLayers);
Y = cell(1,nLayers);
U{1+0} = ...
    initialize_variables_custom(size(batch), {'time', 'chunk'});
U{1+0}.data = batch;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    if isfield(arch, 'banks')
        Y{layer} = U_to_Y(U{1+previous_layer}, arch.banks);
    else
        Y{layer} = U(1+previous_layer);
    end
    if isfield(arch, 'nonlinearity')
        U{1+layer} = Y_to_U(Y{layer}{end}, arch.nonlinearity);
    end
    if isfield(arch, 'invariants')
        S{1+previous_layer} = Y_to_S(Y{layer}, arch);
    end
end
end