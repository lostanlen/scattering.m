function boolean = iskey(key,tree)
if isempty(key)
    boolean = true;
    return
else
    head_name_cell = fieldnames(key);
    head_name = head_name_cell{1};
    if ~isfield(tree,head_name)
        boolean = false;
        return
    else
        head_relative_depth = length(key.(head_name));
        if length(tree.(head_name))~=head_relative_depth
            boolean = false;
            return
        else
            tail = key.(head_name){head_relative_depth};
            subtree = tree.(head_name){head_relative_depth};
            boolean = iskey(tail,subtree);
        end
    end
end
