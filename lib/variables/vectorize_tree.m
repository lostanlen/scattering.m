function leaves = vectorize_tree(tree)
%% Case of empty tree
names = fieldnames(tree);
if isempty(names)
    leaves = [];
    return;
end

%% Leaf switch
if isfield(tree,'leaf')
    leaves = tree.leaf;
else
    leaves = [];
end

%% Branch recursion
name_indices_excluding_leaf = find(cellfun(@(x) ~strcmp(x,'leaf'),names));
for name_index = name_indices_excluding_leaf
    name = names{name_index};
    nDepths = length(tree.(name));
    for depth_index = 1:nDepths
        subtree = tree.(name){depth_index};
        subtree_leaves = vectorize_tree(subtree);
        leaves = cat(1,leaves,subtree_leaves);
    end
end
end
