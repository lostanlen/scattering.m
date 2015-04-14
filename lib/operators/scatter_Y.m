function next_sub_Y = scatter_Y(sub_Y,bank)
%% Cell-wise map
if iscell(sub_Y)
    scatter_handle = @(x) scatter_Y(x,bank);
    next_sub_Y = map_unary(scatter_handle,sub_Y);
    return;
end

%% Variable loading
keys = sub_Y.keys;
ranges = sub_Y.ranges;
variable_tree = sub_Y.variable_tree;
try
    % Loading of relative variables (next sibling and uncle) if they exist
    [sibling,uncle] = get_relatives(bank.behavior.key,variable_tree);
catch err
    % On-the-fly spiraling if the variable j is not found
    if strcmp(err.identifier,'MATLAB:nonExistentField') && ...
            strcmp(get_suffix(bank.behavior.key),'j')
        sub_Y = roll_spiral(sub_Y,bank);
        % Update of variable tree and relative variables
        variable_tree = sub_Y.variable_tree;
        [sibling,uncle] = get_relatives(bank.behavior.key,variable_tree);
    else
        rethrow(err);
    end
end
variable = get_leaf(variable_tree,bank.behavior.key);
% Subscripts and colons are updated according to the network structure
bank.behavior.subscripts = variable.subscripts;
bank.behavior.colons.subs = replicate_colon(length(keys{1+0}));

%% Scattering
if isempty(uncle)
    if isempty(sibling)
        [next_sub_Y.data,next_sub_Y.ranges] = ...
            firstborn_scatter(sub_Y.data_ft,bank,ranges);
    elseif sibling.is_firstborn
        [next_sub_Y.data,next_sub_Y.ranges] = ...
            secondborn_scatter(sub_Y.data_ft,bank,ranges,sibling);
    else
        [next_sub_Y.data,next_sub_Y.ranges] = ...
            sibling_scatter(sub_Y.data_ft,bank,ranges,sibling);
    end
else
    [next_sub_Y.data,next_sub_Y.ranges] = ...
        nephew_scatter(sub_Y.data_ft,bank,ranges,sibling,uncle);
end

%% Update of variable tree and keys array
is_scatter = true;
[next_sub_Y.keys,next_sub_Y.variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle);
end
