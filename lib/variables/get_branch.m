function branch = get_branch(tree,key)
if isempty(key)
    branch = tree;
else
    head_name_cell = fieldnames(key);
    head_name = head_name_cell{1};
    head_relative_depth = length(key.(head_name));
    tail = key.(head_name){head_relative_depth};
    subtree = tree.(head_name){head_relative_depth};
    branch = get_branch(subtree,tail);
end
end
