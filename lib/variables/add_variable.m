function [keys,variable_tree] = ...
    add_variable(keys,variable_tree,key,suffix,leaf,subscript)
%% Subscript inference
nLevels = length(keys) - 1;
level = leaf.level;
if level > nLevels
    nSubscripts = 0;
else
    nSubscripts = length(keys{1+level});
end
if nargin<6
    subscript = nSubscripts + 1;
end

%% Generation of suffixed key
branch = get_branch(variable_tree,key);
if isfield(branch,suffix)
    depth = length(branch.(suffix)) + 1;
else
    depth = 1;
end
suffixed_key = append_suffix(key,suffix,depth);
if level<=nLevels
    keys{1+level}((subscript+1):(end+1)) = keys{1+level}(subscript:end);
end
keys{1+level}{subscript} = suffixed_key;

%% Update of shifted variables
for shifted_subscript = (subscript+1):(nSubscripts+1)
    shifted_key = keys{1+level}{shifted_subscript};
    shifted_variable = get_leaf(variable_tree,shifted_key);
    shifted_variable.subscripts = shifted_variable.subscripts + 1;
    variable_tree = set_leaf(variable_tree,shifted_key,shifted_variable);
end

%% Generation of suffixed variable
leaf.subscripts = subscript;
variable_tree = set_leaf(variable_tree,suffixed_key,leaf);
end
