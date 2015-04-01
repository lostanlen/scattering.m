function next_sub_Y = scatter_Y(sub_Y,bank)
%% Cell-wise map
if iscell(sub_Y)
    scatter_handle = @(x) scatter_Y(x,bank);
    next_sub_Y = map_unary(scatter_handle,sub_Y);
    return;
end

%% Variable loading
keys = sub_Y.keys;
variable_tree = sub_Y.variable_tree;
try
    [sibling,uncle] = get_relatives(bank.behavior.key,variable_tree);
catch err;
    if strcmp(err.identifier,'MATLAB:nonExistentField') && ...
            strcmp(get_suffix(bank.behavior.key),'j')
        sub_Y = roll_spiral(sub_Y,bank);
        variable_tree = sub_Y.variable_tree;
        [sibling,uncle] = get_relatives(bank.behavior.key,variable_tree);
    else
        rethrow(err);
    end
end
variable = get_leaf(variable_tree,bank.behavior.key);
bank.behavior.subscripts = variable.subscripts;
bank.behavior.colons.subs = replicate_colon(length(keys{1+0}));

%% Scattering
if isempty(uncle)
    if isempty(sibling)
        level_counter = length(keys)-1 - 1;
        bank = firstborn_scatter_bank(bank);
        next_sub_Y.data = firstborn_scatter(sub_Y.data_ft, ...
            bank,level_counter);
    else
        sibling_level_counter = length(keys)-1 - (sibling.level+1);
        bank = sibling_scatter_bank(bank,sibling);
        if sibling.is_firstborn
            next_sub_Y.data = secondborn_scatter(sub_Y.data_ft, ...
                bank,sibling_level_counter);
        else
            next_sub_Y.data = sibling_scatter(sub_Y.data_ft, ...
                bank,sibling_level_counter);
        end
    end
else
    uncle_level_counter = length(keys)-1 - uncle.level;
    next_sub_Y.data = nephew_scatter(sub_Y.data_ft, ...
        bank,sibling,uncle,uncle_level_counter);
end

%% Update of variable tree and keys array
is_scatter = true;
[next_sub_Y.keys,next_sub_Y.variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle);
end
