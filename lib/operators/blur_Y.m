function next_sub_Y = blur_Y(sub_Y,bank)
%% Cell-wise map
if iscell(sub_Y)
    blur_handle = @(x) blur_Y(x,bank);
    next_sub_Y = map_unary(blur_handle,sub_Y);
    return
end

%% Variable loading
keys = sub_Y.keys;
variable_tree = sub_Y.variable_tree;
try
    [sibling,uncle] = get_relatives(bank.behavior.key,variable_tree);
catch err
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
% Subscripts and colons are updated according to the network structure
bank.behavior.subscripts = variable.subscripts;
if variable.subscripts(1)>1
    bank.phi = permute_subscript(bank.phi,bank.behavior.subscripts);
end
bank.behavior.colons = substruct('()',replicate_colon(length(keys{1+0})));
if isfield(bank.behavior, 'spiral')
    bank.behavior.spiral.subscript = ...
        variable_tree.time{1}.gamma{1}.leaf.subscripts;
end

%% Blurring
if isempty(sibling)
    [next_sub_Y.data,next_sub_Y.ranges] = ...
        firstborn_blur(sub_Y.data_ft,bank,sub_Y.ranges);
elseif sibling.nSiblings==0
    [next_sub_Y.data,next_sub_Y.ranges] = ...
        secondborn_blur(sub_Y.data_ft,bank,sub_Y.ranges,sibling);
else
    [next_sub_Y.data,next_sub_Y.ranges] = ...
        sibling_blur(sub_Y.data_ft,bank,sub_Y.ranges,sibling);
end

%% Update of variable tree and keys array
is_scatter = false;
[next_sub_Y.keys,next_sub_Y.variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle);
end