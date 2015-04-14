function previous_sub_dY = dual_scatter_dY(sub_Y,bank,previous_sub_dY)
%% Cell-wise map
if iscell(sub_Y)
    dual_scatter_handle = @(x,y) dual_scatter_dY(x,bank,y);
    previous_sub_dY = ...
        map_unary_inplace(dual_scatter_handle,sub_Y,previous_sub_dY);
    return
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

%% Dual scattering
if isempty(uncle)
    if isempty(sibling)
        previous_sub_dY.data_ft = ...
            dual_firstborn_scatter(sub_Y.data,bank,ranges, ...
                previous_sub_dY.data,previous_sub_dY.ranges);
    elseif sibling.is_firstborn
        previous_sub_dY.data_ft = ...
            dual_secondborn_scatter(sub_Y.data,bank,ranges,sibling, ...
                previous_sub_dY.data,previous_sub_dY.ranges);
    else
        previous_sub_dY.data_ft = ...
            dual_sibling_scatter(sub_Y.data,bank,ranges,sibling, ...
                previous_sub_dY.data,previous_sub_dY.ranges);
    end
else
    previous_sub_dY.data_ft = ...
        dual_nephew_scatter(sub_Y.data,bank,ranges,sibling,uncle, ...
            previous_sub_dY.data,previous_sub_dY.ranges);
end
end