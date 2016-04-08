function target_S = eca_target(y, archs)
nLayers = length(archs);
target_S = cell(1, nLayers);
target_U = cell(1, nLayers);
target_Y = cell(1, nLayers);
target_U{1+0} = initialize_variables_auto(size(y));
target_U{1+0}.data = y;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    if isfield(arch, 'banks')
        target_Y{layer} = U_to_Y(target_U{1+previous_layer}, arch.banks);
    else
        target_Y{layer} = target_U(1+previous_layer);
    end
    
    % Apply nonlinearity to last sub-layer Y to get layer U
    if isfield(arch, 'nonlinearity')
        target_U{1+layer} = Y_to_U(target_Y{layer}{end}, arch.nonlinearity);
    end
    
    % Blur/pool first layer Y to get layer S
    if isfield(arch, 'invariants')
        target_S{1+previous_layer} = Y_to_S(target_Y{layer}, arch);
    end
end
end