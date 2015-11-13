function next_sub_Y = sum_Y(sub_Y, invariant)
%% Cell-wise map
if iscell(sub_Y)
    sum_handle = @(x) sum_Y(x, invariant);
    next_sub_Y = map_unary(sum_handle, sub_Y);
    return
end

%% Get subscripts of summed variable
leaf = get_leaf(sub_Y.variable_tree, invariant.behavior.key);
subscripts = leaf.subscripts;

end

