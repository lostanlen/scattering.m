function difference = map_substract(minuend,subtrahend)
%%
if isempty(minuend.data) || isempty(subtrahend.data)
    difference = [];
    return;
end

top_keys = minuend.keys{end};
nTop_keys = length(top_keys);
minuend_substruct = substruct('()',replicate_colon(nTop_keys));
subtrahend_substruct = minuend_substruct;
difference = minuend;
for top_key_index = 1:nTop_keys
    key = top_keys{top_key_index};
    suffix = get_suffix(key);
    if strcmp(suffix,'gamma')
        minuend_variable = get_leaf(minuend.variable_tree,key);
        subtrahend_variable = get_leaf(subtrahend.variable_tree,key);
        difference_variable = minuend_variable;
        minuend_gammas = [minuend_variable.metas.gamma];
        subtrahend_gammas = [subtrahend_variable.metas.gamma];
        % TODO: intersect these two above with
        % metas.max_sibling_gamma of younger sibling
        [~,minuend_indices,subtrahend_indices] = ...
            intersect(minuend_gammas,subtrahend_gammas);
        subscripts = minuend_variable.subscripts;
        minuend_substruct.subs{subscripts} = minuend_indices;
        subtrahend_substruct.subs{subscripts} = subtrahend_indices;
        difference_variable.metas = minuend_variable.metas(minuend_indices);
        difference.variable_tree = ...
            set_leaf(difference.variable_tree,key,difference_variable);
    end
end

%%
minuend.data = subsref(minuend.data,minuend_substruct);
subtrahend.data = subsref(subtrahend.data,subtrahend_substruct);

if length(minuend.keys)>1
    %%
    minuend.keys = minuend.keys(1:(end-1));
    subtrahend.keys = subtrahend.keys(1:(end-1));
    nCells = numel(minuend.data);
    minuend_cell = minuend;
    subtrahend_cell = subtrahend;
    for cell_index = 1:nCells
        minuend_cell.data = minuend.data{cell_index};
        subtrahend_cell.data = subtrahend.data{cell_index};
        difference.data{cell_index} = ...
            map_substract(minuend_cell,subtrahend_cell);
    end
else
    difference.data = minuend.data - subtrahend.data;
end
end
