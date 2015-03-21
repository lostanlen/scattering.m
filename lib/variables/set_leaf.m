function tree = set_leaf(tree,key,leaf)
if isempty(key)
    tree.leaf = leaf;
else
    head_name_cell = fieldnames(key);
    head_name = head_name_cell{1};
    head_relative_depth = length(key.(head_name));
    tail = key.(head_name){head_relative_depth};
    if isfield(tree,head_name)
        nDepths = length(tree.(head_name));
        if head_relative_depth > nDepths
            tree.(head_name){head_relative_depth} = struct();
        end
    else
        tree.(head_name) = cell(1,head_relative_depth);
    end
    subtree = tree.(head_name){head_relative_depth};
    tree.(head_name){head_relative_depth} = set_leaf(subtree,tail,leaf);
end
end
