function leaf = get_leaf(tree,key)
if isempty(key)
    leaf = tree.leaf;
else
    head_name_cell = fieldnames(key);
    head_name = head_name_cell{1};
    head_relative_depth = length(key.(head_name));
    tail = key.(head_name){head_relative_depth};
    try
        subtree = tree.(head_name){head_relative_depth};
        leaf = get_leaf(subtree,tail);
    catch ME
        if strcmp(ME.identifier,'MATLAB:badsubscript')
            leaf = [];
            return
        else
            rethrow(ME);
        end
    end
end
end
