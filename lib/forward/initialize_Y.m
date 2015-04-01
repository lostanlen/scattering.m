function layer_Y1 = initialize_Y(layer_U,layer_banks)
%% Cell-wise map
if iscell(layer_U)
    initialization_handle = @(x) initialize_Y(x,layer_banks);
    layer_Y1 = map_unary(initialization_handle,layer_U);
    return;
end

%% Search for the unpadded variables to be scattered
variable_tree = layer_U.variable_tree;
nVariables_to_transform = length(layer_banks);
padding_variables = [];
for variable_index = 1:nVariables_to_transform
    bank = layer_banks{variable_index};
    bank_behavior = bank.behavior;
    key = bank_behavior.key;
    if ~iskey(key,variable_tree)
        continue;
    end
    variable = get_leaf(variable_tree,key);
    if variable.level==0 && ~isfield(variable,'padding')
        variable.padding = bank_behavior.padding;
        variable_tree = set_leaf(variable_tree,key,variable);
        padding_variables = cat(1,padding_variables,variable);
    end
end

%% Padding
if isempty(padding_variables)
    layer_Y1 = layer_U;
else
    padding_handle = @(x) sc_pad(x,padding_variables);
    layer_Y1.data = map_unary(padding_handle,layer_U.data);
    layer_Y1.keys = layer_U.keys;
    layer_Y1.variable_tree = variable_tree;
end
end
