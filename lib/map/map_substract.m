function difference = map_substract(minuend,subtrahend)
%% Return empty array if any the operand is empty
if isempty(minuend.data) || isempty(subtrahend.data)
    difference = struct('data',[]);
    return;
end

%% Initialize substructs and output structure
top_keys = minuend.keys{end};
nTop_keys = length(top_keys);
minuend_substruct = substruct('()',replicate_colon(nTop_keys));
subtrahend_substruct = minuend_substruct;
difference = minuend;

%% For every key at the top level of variable tree
for top_key_index = 1:nTop_keys
    key = top_keys{top_key_index};
    [suffix_name,suffix_depth] = get_suffix(key);
    %% If the key is of the form gamma::V
    % take the intersection of available gammas in minuend and subtrahend
    if strcmp(suffix_name,'gamma')
        minuend_variable = get_leaf(minuend.variable_tree,key);
        subtrahend_variable = get_leaf(subtrahend.variable_tree,key);
        difference_variable = minuend_variable;
        minuend_gammas = [minuend_variable.metas.gamma];
        subtrahend_gammas = [subtrahend_variable.metas.gamma];
        % If the key has a younger sibling, apply the inequality between gammas
        % Ex: if key is gamma, apply gamma < gamma_2.
        father_key = remove_suffix(key);
        sibling_key = append_suffix(father_key,'gamma',suffix_depth+1);
        sibling_leaf = get_leaf(minuend.variable_tree,sibling_key);
        if ~isempty(sibling_leaf)
            branch_index = sibling_leaf.branch_index;
            max_gamma = sibling_leaf.metas(branch_index).max_sibling_gamma;
            minuend_gammas = minuend_gammas(minuend_gammas<=max_gamma);
            subtrahend_gammas = subtrahend_gammas(subtrahend_gammas<=max_gamma);
        end
        % TODO: write a fast_ismembc to replace intersection of sorted arrays
        [~,minuend_indices,subtrahend_indices] = ...
            intersect(minuend_gammas,subtrahend_gammas);
        subscripts = minuend_variable.subscripts;
        minuend_substruct.subs{subscripts} = minuend_indices;
        subtrahend_substruct.subs{subscripts} = subtrahend_indices;
        difference_variable.metas = minuend_variable.metas(minuend_indices);
        difference.variable_tree = ...
            set_leaf(difference.variable_tree,key,difference_variable);
    %% If the key is of the form j::V
    % take the intersection of available js in minuend and subtrahend
    elseif strcmp(suffix_name,'j')
        % TODO: write spiral case
    end
end

%% Truncate minuend data and subtrahend data to common elements
minuend.data = subsref(minuend.data,minuend_substruct);
subtrahend.data = subsref(subtrahend.data,subtrahend_substruct);

%% If the variable tree is deep, recurse across nested levels
if length(minuend.keys)>1
    %% Initialize minuend_cell and subtrahend_cell
    minuend.keys = minuend.keys(1:(end-1));
    subtrahend.keys = subtrahend.keys(1:(end-1));
    data_sizes = size(minuend.data);
    nCells = prod(data_sizes);
    minuend_cell = minuend;
    subtrahend_cell = subtrahend;
    %% If the variable tree has width>1 as the top
    % (this happend e.g. at level 1 in spiral scattering)
    % We use Cartesian indexing with ind2sub to annotate the branches.
    if nTop_keys>1
        nSubscripts = drop_trailing(length(data_sizes));
        [minuend_cartesians{1:nSubscripts}] = ...
            ind2sub(data_sizes,minuend_indices);
        for cell_index = 1:nCells
            minuend_cell.data = minuend.data{cell_index};
            for top_key_index = 1:nTop_keys
                branch_index = minuend_cartesians{top_key_index}(cell_index);
                key = top_keys{top_key_index};
                % TODO: rewrite this as update_leaf (faster than get and set)
                minuend_variable = get_leaf(minuend.variable_tree,key);
                minuend_variable.branch_index = branch_index;
                minuend_cell.variable_tree = ...
                    set_leaf(minuend_cell,key,minuend_variable);
            end
            subtrahend_cell.data = subtrahend.data{cell_index};
            % Recursive call
            difference_cell = map_substract(minuend_cell,subtrahend_cell);
            difference.data{cell_index} = difference_cell.data;
        end
    else
        %% If the variable tree has width==1 at the top
        % (this happens e.g. in plain and time-frequency scattering)
        % In this case, we may use linear indexing as a surrogate for Cartesian
        % indexing.
        for cell_index = 1:nCells
            minuend_cell.data = minuend.data{cell_index};
            minuend_variable.branch_index = cell_index;
            minuend_cell.variable_tree = ...
                set_leaf(minuend_cell.variable_tree,key,minuend_variable);
            subtrahend_cell.data = subtrahend.data{cell_index};
            % Recursive call
            difference_cell = map_substract(minuend_cell,subtrahend_cell);
            difference.data{cell_index} = difference_cell.data;
        end
    end
else
%% Once at the bottom level, just substract tensors
    difference.data = minuend.data - subtrahend.data;
end
end
