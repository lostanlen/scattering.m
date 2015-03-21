function tree_out = remove_key(tree_in,key)
tree_out = tree_in;
if isempty(key)
    tree_out = tree_in;
else
    head_name_cell = fieldnames(key);
    head_name = head_name_cell{1};
    head_relative_depth = length(key.(head_name));
    tail = key.(head_name){head_relative_depth};
    if isempty(tail)
        tree_out.(head_name){head_relative_depth} = [];
        emptiness_array = cellfun(@isempty,tree_out.(head_name));
        last_nonempty_index = find(~emptiness_array,1,'last');
        if isempty(last_nonempty_index)
            tree_out = rmfield(tree_out,head_name);
        else
            tree_out.(head_name) = ...
                tree_out.(head_name)(1:last_nonempty_index);
        end
    else
        subtree = tree_out.(head_name){head_relative_depth};
        tree_out.(head_name){head_relative_depth} = ...
            remove_key(subtree,tail);
    end
end
