function layer = unspiral_metadata(layer)
%% Deep map across cells
if iscell(layer)
    for cell_index = 1:numel(layer)
        if ~isempty(layer{cell_index})
            layer{cell_index} = unspiral_metadata(layer{cell_index});
        end
    end
else
    % Remove octave key
    % This is needed when backpropagating from spiral scattering
    octave_key.time{1}.j = cell(1);
    nTensor_subscripts = length(layer.keys{1});
    for subscript_index = 1:nTensor_subscripts
        suffix_name = get_suffix(layer.keys{1}{subscript_index});
        if strcmp(suffix_name,'j')
            layer.keys{1} = ...
                layer.keys{1}((1:nTensor_subscripts)~=subscript_index);
            break
        end
    end
    layer.variable_tree = remove_key(layer.variable_tree,octave_key);
end
end