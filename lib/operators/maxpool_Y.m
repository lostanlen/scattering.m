function next_sub_Y = maxpool_Y(sub_Y, invariant)
%% Cell-wise map
if iscell(sub_Y)
    sum_handle = @(x) maxpool_Y(x, invariant);
    next_sub_Y = map_unary(sum_handle, sub_Y);
    return
end

%% Get subscripts of summed variable
key = invariant.behavior.key;
leaf = get_leaf(sub_Y.variable_tree, key);
subscripts = leaf.subscripts;

%% Reduce all tensors along these subscripts
next_sub_Y = sub_Y;
next_sub_Y.data = map_maxpool(sub_Y.data, subscripts);

%% Update ranges
next_sub_Y.ranges{1+0} = map_collapse_ranges(sub_Y.ranges{1+0}, subscripts);
end

