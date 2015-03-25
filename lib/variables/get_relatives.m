function [sibling,uncle] = get_relatives(key,variable_tree)
%%
head_name_cell = fieldnames(key);
head_name = head_name_cell{1};
head_relative_depth = length(key.(head_name));
tail = key.(head_name){head_relative_depth};
branch = variable_tree.(head_name){head_relative_depth};
if isempty(tail)
    if isfield(branch,'gamma')
        sibling = branch.gamma{end}.leaf;
        sibling.is_firstborn = (length(branch.gamma)==1);
    else
        sibling = [];
    end
    uncle = [];
    return;
end
tail_head_name_cell = fieldnames(tail);
tail_head_name = tail_head_name_cell{1};
tail_head_relative_depth = length(tail.(tail_head_name));
tail_tail = tail.(tail_head_name){tail_head_relative_depth};
branch_branch = branch.(tail_head_name){tail_head_relative_depth};
if isempty(tail_tail)
    if strcmp(tail_head_name,'gamma') || strcmp(tail_head_name,'j')
        if length(branch.gamma)>head_relative_depth
            uncle = branch.gamma{head_relative_depth+1}.leaf;
        else
            uncle = [];
        end
    else
        uncle = [];
    end
    if isfield(branch_branch,'gamma')
        sibling = branch_branch.gamma{tail_head_relative_depth+1}.leaf;
        sibling.is_firstborn = (length(branch_branch.gamma)==1);
    else
        sibling = [];
    end
    return;
end
[sibling,uncle] = get_relatives(key,variable_tree_tail);
end
