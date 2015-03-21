function filtered_tree = filter_tree(filter_handle,tree)
if isfield(tree,'leaf') && filter_handle(tree.leaf)
    filtered_tree.leaf = tree.leaf;
else
    filtered_tree = struct();
end
names = fieldnames(tree);
name_indices_excluding_leaf = find(cellfun(@(x) ~strcmp(x,'leaf'),names));
for name_index = name_indices_excluding_leaf
    name = names{name_index};
    nDepths = length(tree.(name));
    for depth_index = 1:nDepths
        subtree = tree.(name){depth_index};
        filtered_subtree = filter_tree(filter_handle,subtree);
        if ~isempty(fieldnames(filtered_subtree))
            filtered_tree.(name){depth_index} = filtered_subtree;
        end
    end
end
end
