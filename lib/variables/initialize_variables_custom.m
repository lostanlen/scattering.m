function [variable_tree,keys] = ...
    initialize_variables_custom(original_sizes,names)
variable_tree = struct();
nNames = length(names);
keys{1+0} = cell(1,nNames);
name_index = 0;
nItems = 0;
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
end
