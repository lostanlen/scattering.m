function [sibling,uncle,gamma_variable] = dual_get_relatives(key,variable_tree)
%%
head_name_cell = fieldnames(key);
head_name = head_name_cell{1};
head_relative_depth = length(key.(head_name));
tail = key.(head_name){head_relative_depth};
branch = variable_tree.(head_name){head_relative_depth};
if isempty(tail)
    if isfield(branch,'gamma')
        gamma_variable = branch.gamma{end}.leaf;
        if length(branch.gamma)>1
            sibling = branch.gamma{end-1}.leaf;
            sibling.nSiblings = length(branch.gamma) - 2;
        else
            sibling = [];
        end
    end
    uncle = [];
    return
end
tail_head_name_cell = fieldnames(tail);
tail_head_name = tail_head_name_cell{1};
tail_head_relative_depth = length(tail.(tail_head_name));
tail_tail = tail.(tail_head_name){tail_head_relative_depth};
branch_branch = branch.(tail_head_name){tail_head_relative_depth};
if isempty(tail_tail)
    if strcmp(tail_head_name,'gamma') || strcmp(tail_head_name,'j')
        if length(branch.gamma)>head_relative_depth
            uncle = branch.gamma{head_relative_depth}.leaf;
        else
            uncle = [];
        end
    else
        uncle = [];
    end
    if isfield(nranch_branch,'gamma')
        gamma_variable = branch_branch.gamma{end}.leaf;
        if length(branch_branch.gamma)>1
            sibling = branch_branch.gamma{end-1}.leaf;
            sibling.nSiblings = length(branch_branch.gamma) - 2;
        else
            sibling = [];
        end
    end
    return
end
[sibling,uncle,gamma_variable] = dual_get_relatives(key,variable_tree_tail);
end
