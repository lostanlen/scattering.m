function previous_sub_dY = dual_blur_dY(sub_dY,bank)
%% Cell-wise map
if iscell(sub_dY)
    blur_handle = @(x) dual_blur_dY(x,bank);
    previous_sub_dY = map_unary(blur_handle,sub_dY);
    return
end

%% Variable loading
keys = sub_dY.keys;
variable_tree = sub_dY.variable_tree;
try
    sibling = get_relatives(bank.behavior.key,variable_tree);
catch err
    if strcmp(err.identifier,'MATLAB:nonExistentField') && ...
            strcmp(get_suffix(bank.behavior.key),'j')
        sub_dY = unroll_spiral(sub_dY,bank);
        variable_tree = sub_dY.variable_tree;
        sibling = get_relatives(bank.behavior.key,variable_tree);
    else
        rethrow(err);
    end
end
variable = get_leaf(variable_tree,bank.behavior.key);
bank.behavior.subscripts = variable.subscripts;
bank.behavior.colons = substruct('()',replicate_colon(length(keys{1+0})));

%% Dual blurring
if isempty(sibling)
    previous_sub_dY.data_ft = ...
        dual_firstborn_blur(sub_dY.data,bank,sub_dY.ranges);
elseif sibling.is_firstborn
    previous_sub_dY.data_ft= ...
        dual_secondborn_blur(sub_dY.data,bank,sub_dY.ranges,sibling);
else
    previous_sub_dY.data_ft = ...
        dual_sibling_blur(sub_dY.data,bank,sub_dY.ranges,sibling);
end
end