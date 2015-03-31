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
        throw(err);
    end
end

%% Blurring with phi
% Adaptation of the number of colons in bank_behavior if necessary.
% This is especially needed at the last layer.
nColons = length(sub_Y.keys{1+0});
if nColons==6
    disp(nColons);
end
bank.behavior.colons = substruct('()',replicate_colon(nColons));

if isempty(uncle)
    if isempty(sibling)
        level_counter = length(keys)-1 - 1;
        bank = firstborn_blur_bank(bank);
        next_sub_Y.data = firstborn_blur(sub_Y.data_ft, ...
            bank,level_counter);
    else
        sibling_level_counter = length(keys)-1 - sibling.level;
        bank = sibling_blur_bank(bank,sibling);
        if sibling.is_firstborn
            next_sub_Y.data = secondborn_blur(sub_Y.data_ft, ...
                bank,sibling_level_counter);
        else
            next_sub_Y.data = sibling_blur(sub_Y.data_ft, ...
                bank,sibling_level_counter);
        end
    end
else
    uncle_level_counter = length(keys)-1 - uncle.level;
    next_sub_Y.data = nephew_blur(sub_Y.data_ft, ...
        bank,sibling,uncle,uncle_level_counter);
end

%% Update of variable tree and keys array
is_scatter = false;
[next_sub_Y.keys,next_sub_Y.variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle);
end
