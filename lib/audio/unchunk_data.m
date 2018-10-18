function unchunked_data = unchunk_data(data, root_leaf)
%% Deep map across cells
if iscell(data)
    nCells = numel(data);
    unchunked_data = cell(size(data));
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        if isempty(data_cell)
            continue
        end
        unchunked_data{cell_index} = unchunk_data(data_cell, root_leaf);
    end
%% Data unchunking
else
    data_sizes = size(data);
    chunk_length = data_sizes(1);
    nChunks = data_sizes(2);
    if chunk_length == 1
        unchunked_data = reshape(data, [data_sizes(2:end),1]);
        return
    end
    nHops_per_chunk = chunk_length * (1 - 2*root_leaf.T/root_leaf.size);
    unchunked_length = nChunks * nHops_per_chunk;
    unchunked_sizes = [unchunked_length, data_sizes(3:end)];
    unchunked_data = zeros([unchunked_sizes, 1]);
    nSubscripts = length(data_sizes);
    subsref_structure = substruct('()', replicate_colon(nSubscripts));
    subsasgn_structure = substruct('()', replicate_colon(nSubscripts-1));
    for chunk_index = 1:nChunks
        subsref_structure.subs{2} = chunk_index;
        if strcmp(root_leaf.windowing, 'tukey')
            chunk_subsref_start = ...
                1 + (root_leaf.T/root_leaf.size) * chunk_length;
            chunk_subsasgn_start = ...
                1 + nHops_per_chunk * (chunk_index-1);
            chunk_subsref_stop = ...
                (1 - root_leaf.T/root_leaf.size) * chunk_length;
            chunk_subsasgn_stop = nHops_per_chunk * chunk_index;
        elseif strcmp(root_leaf.windowing, 'hann')
            chunk_subsasgn_start = 1 + chunk_length * (chunk_index-1);
            chunk_subsasgn_stop = chunk_length * chunk_index;
            chunk_subsref_start = 1;
            chunk_subsref_stop = chunk_length;
        end
        subsref_structure.subs{1} = ...
            chunk_subsref_start:chunk_subsref_stop;
        subsasgn_structure.subs{1} = ...
            chunk_subsasgn_start:chunk_subsasgn_stop;
        chunk_subsref = subsref(data, subsref_structure);
        chunk_subsref_sizes = size(chunk_subsref);
        chunk_subsref = reshape(chunk_subsref, ....
            [chunk_subsref_sizes(1), chunk_subsref_sizes(3:end), 1]);
        if strcmp(root_leaf.windowing, 'tukey')
            chunk_subsasgn = chunk_subsref;
        elseif strcmp(root_leaf.windowing, 'hann')
            chunk_subsasgn = chunk_subsref + ...
                subsref(unchunked_data, subsasgn_structure);
        end
        unchunked_data = ...
            subsasgn(unchunked_data, subsasgn_structure, chunk_subsasgn);
    end
    
    % Unpadding
    subsref_structure = subsasgn_structure;
    subsref_structure.subs{1} = ...
        1:round(root_leaf.unpadded_size * chunk_length/root_leaf.size);
    unchunked_data = subsref(unchunked_data, subsref_structure);
end
end
