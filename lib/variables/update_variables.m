function [keys,variable_tree] = ...
    update_variables(keys,variable_tree,bank,is_scatter,sibling,uncle)
key = bank.behavior.key;
if isempty(sibling)
    gamma_level = 1;
elseif length(sibling.nSiblings)==1
    % Downgrade first-born sibling
    gamma_level = 1;
    sibling_subscript = sibling.subscripts;
    if sibling.subscripts>length(keys{1+1})
        % This needs to decrement the subscripts of depth-one variables
        % whose subscript is above sibling_subscript
        error('middle-subscript first-born downgrading not ready yet');
    end
    sibling_key = keys{1+1}{sibling_subscript};
    keys{1+0}{end+1} = sibling_key;
    keys{1+1}(sibling_subscript) = [];
    sibling.level = 0;
    sibling.subscripts = length(keys{1+0});
    sibling.padding = parse_padding('zero');
    variable_tree = set_leaf(variable_tree,sibling_key,sibling);
else
    gamma_level = sibling.level + 1;
end

if ~isempty(uncle) && uncle.level<=gamma_level && is_scatter
    % Upgrade uncle
    uncle_subscript = uncle.subscripts;
    uncle_level = uncle.level;
    if uncle_subscript>length(keys{1+uncle_level})
        % This needs to decrement the subscripts of depth-one variables
        % whose subscript is below uncle_subscript
        error('middle-subscript uncle upgrading not ready yet');
    end
    uncle_key = keys{1+uncle_level}{uncle_subscript};
    if length(keys)<(1+uncle_level+1)
        keys{end+1}{1} = uncle_key;
    else
        keys{1+uncle_level+1}{end} = uncle_key;
    end
    keys{1+uncle_level}(uncle_subscript) = [];
    uncle.level = uncle.level + 1;
    uncle.subscripts = length(keys{1+uncle_level+1});
    variable_tree = set_leaf(variable_tree,uncle_key,uncle);
end

%%
if is_scatter
    gamma_leaf = struct( ...
        'behavior',bank.behavior, ...
        'level',gamma_level, ...
        'metas',bank.metas, ...
        'spec',bank.spec);
    [keys,variable_tree] = ...
        add_variable(keys,variable_tree,key,'gamma',gamma_leaf);
    if bank.spec.nThetas>1
        theta_leaf.original_sizes = bank.spec.nThetas;
        theta_leaf.level = 0;
        [keys,variable_tree] = ...
            add_variable(keys,variable_tree,key,'theta',theta_leaf);
    end
else
    variable = get_leaf(variable_tree,key);
    log2_oversampling = bank.behavior.S.log2_oversampling;
    variable.log2_sampling = 1 - bank.spec.J + log2_oversampling;
    variable_tree = set_leaf(variable_tree,key,variable);
end
%%
if isfield(bank.behavior,'spiral') && ~strcmp(get_suffix(key),'j')
    spiraled_subscript = bank.behavior.spiral.subscript;
    spiraled_key = keys{1+0}{spiraled_subscript};
    father_key = remove_suffix(spiraled_key);
    octave_leaf.level = 0;
    octave_leaf.padding = parse_padding('zero');
    octave_subscript = spiraled_subscript + 1;
    [keys,variable_tree] = add_variable(keys,variable_tree, ...
        father_key,'j',octave_leaf,octave_subscript);
end

%%
nLayers = find(~cellfun(@isempty,keys),1,'last');
keys = keys(1:nLayers);
