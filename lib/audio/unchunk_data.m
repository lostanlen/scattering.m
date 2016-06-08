function unchunked_data = unchunk_data(data)
%% Deep map across cells
if iscell(data)
    nCells = numel(data);
    unchunked_data = cell(size(data));
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        if isempty(data_cell)
            continue
        end
        unchunked_data{cell_index} = unchunk_data(data_cell);
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
    nHops_per_chunk = 2;
    hop_length = chunk_length / nHops_per_chunk;
    unchunked_length = hop_length * (nChunks - nHops_per_chunk + 1);
    unchunked_sizes = [unchunked_length, data_sizes(3:end)];
    unchunked_data = zeros([unchunked_sizes, 1]);
    nSubscripts = length(data_sizes);
    subsref_structure = substruct('()', replicate_colon(nSubscripts));
    subsasgn_structure = substruct('()', replicate_colon(nSubscripts-1));
    for chunk_index = 1:nChunks
        subsref_structure.subs{2} = chunk_index;
        chunk_start = hop_length * (chunk_index-nHops_per_chunk) + 1;
        chunk_stop = chunk_start + chunk_length - 1;
        if chunk_start < 1
            subsref_structure.subs{1} = (2-chunk_start):chunk_length;
            chunk_start = 1;
        elseif chunk_stop > unchunked_length
            subsref_structure.subs{1} = 1:(chunk_length-chunk_stop+unchunked_length);
            chunk_stop = unchunked_length;
        else
            subsref_structure.subs{1} = ':';
        end
        subsasgn_structure.subs{1} = chunk_start:chunk_stop;
        chunk = subsref(data, subsref_structure) + ...
            subsref(unchunked_data, subsasgn_structure);
        unchunked_data = ...
            subsasgn(unchunked_data, subsasgn_structure, chunk);
    end
end
end
