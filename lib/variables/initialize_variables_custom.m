function U0 = initialize_variables_custom(original_sizes,names)
variable_tree = struct();
nNames = length(names);
keys{1+0} = cell(1,nNames);
name_index = 0;
nItems = 0;
nDimensions = length(drop_trailing(original_sizes));
while nItems<nDimensions
    name_index = name_index + 1;
    name = names{name_index};
    items = strfind(names,name);
    subscripts = find(~cellfun(@isempty,items));
    variable_key.(name) = {};
    variable.level = 0;
    variable.original_sizes = original_sizes(subscripts);
    variable.subscripts = subscripts;
    variable_tree = set_leaf(variable_tree,variable_key,variable);
    keys{1+0}{variable.subscripts} = variable_key;
    nItems = nItems + length(subscripts);
end
ranges{1+0} = ...
    arrayfun(@(x) [1,1,original_sizes(x)],1:nDimensions,'UniformOutput',false);

%% Output storage
U0.keys = keys;
U0.ranges = ranges;
U0.variable_tree = variable_tree;
end
