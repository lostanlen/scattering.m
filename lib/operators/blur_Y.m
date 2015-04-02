function next_sub_Y = blur_Y(sub_Y,bank)
%% Cell-wise map
if iscell(sub_Y)
    blur_handle = @(x) blur_Y(x,bank);
    next_sub_Y = map_unary(blur_handle,sub_Y);
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
% Adaptation of the number of colons in bank_behavior if necessary.
% This is especially needed at the last layer.
nColons = length(sub_Y.keys{1+0});
bank.behavior.colons = substruct('()',replicate_colon(nColons));

%% Blurring
if isempty(uncle)
    if isempty(sibling)
        [next_sub_Y.data,next_sub_Y.ranges] = ...
            firstborn_blur(sub_Y.data_ft,bank,sub_Y.ranges);
    else
        if sibling.is_firstborn
            [next_sub_Y.data,next_sub_Y.ranges] = ...
                secondborn_blur(sub_Y.data_ft,bank,sub_Y.ranges,sibling);
        else
            [next_sub_Y.data,next_sub_Y.ranges] = ...
                sibling_blur(sub_Y.data_ft,bank,sub_Y.ranges,sibling);
        end
    end
else
    [next_sub_Y.data,next_sub_Y.ranges] = ...
                nephew_blur(sub_Y.data_ft,bank,sub_Y.ranges,sibling,uncle);
end

%% Update of variable tree and keys array
is_scatter = false;
[next_sub_Y.keys,next_sub_Y.variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle);
end