function layer_U = apply_nonlinearity(nonlinearity,sub_Y,mask)
%% Cell-wise map
if iscell(sub_Y)
    data_sizes = size(sub_Y);
    nCells = prod(data_sizes);
    vectorized_output = cell(1,nCells);
    if iscell(sub_Y{1})
        nonlinearity_handle = @(x) apply_nonlinearity(nonlinearity,x);
        for cell_index = 1:nCells
            if mask(cell_index)
                vectorized_output{cell_index} = ...
                    map_unary(nonlinearity_handle,sub_Y{cell_index}(:));
            else
                vectorized_output{cell_index} = [];
            end
        end
    else
        for cell_index = 1:nCells
            sub_Y_cell = sub_Y{cell_index};
            if ~isempty(sub_Y_cell) && mask(cell_index)
                vectorized_output{cell_index} = ...
                    apply_nonlinearity(nonlinearity,sub_Y_cell);
            else
                vectorized_output{cell_index} = [];
            end
        end
    end
    layer_U = reshape(vectorized_output,data_sizes);
    return
end

%%
if nonlinearity.is_modulus
    layer_U.data = map_unary(@abs,sub_Y.data);
elseif nonlinearity.is_uniform_log
    log_handle = @(x) log1p(abs(x)/nonlinearity.denominator);
    layer_U.data = map_unary(log_handle,sub_Y.data);
elseif nonlinearity.is_custom
    layer_U.data = map_unary(nonlinearity.handle,sub_Y.data);
end

%%
layer_U.keys = sub_Y.keys;
layer_U.ranges = sub_Y.ranges;
layer_U.variable_tree = sub_Y.variable_tree;
end
