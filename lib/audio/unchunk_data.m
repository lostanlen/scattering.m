function unchunked_data = unchunk_data(data,chunk_subscript)
%% Deep map across cells
if iscell(data)
    nCells = numel(data);
    unchunked_data = cell(size(data));
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        if isempty(data_cell)
            continue
        end
        unchunked_data{cell_index} = unchunk_data(data_cell,chunk_subscript);
    end
%% Data unchunking
else
    if ~isequal(chunk_subscript,2)
        error('Unchunking for chunk subscript~=2 not ready');
    end
    data_sizes = size(data);
    chunk_signal_size = data_sizes(1);
    nChunks = data_sizes(2);
    hop_signal_size = chunk_signal_size/2;
    unchunked_sizes = [data_sizes(1)*data_sizes(2)/2,data_sizes(3:end)];
    unchunked_data = zeros([unchunked_sizes,1]);
    rhs_start = 1 + chunk_signal_size/4;
    rhs_end = 3/4 * chunk_signal_size;
    rhs_indices = rhs_start:rhs_end;
    nSubscripts = length(data_sizes);
    subsref_structure = substruct('()',replicate_colon(nSubscripts));
    subsref_structure.subs{1} = rhs_indices;
    subsasgn_structure = substruct('()',replicate_colon(nSubscripts-1));
    for chunk_index = 1:nChunks
        subsref_structure.subs{2} = chunk_index;
        unpadded_chunk = subsref(data,subsref_structure);
        lhs_start = hop_signal_size * (chunk_index-1) + 1;
        lhs_end = lhs_start + chunk_signal_size/2 - 1;
        lhs_indices = lhs_start:lhs_end;
        subsasgn_structure.subs{1} = lhs_indices;
        unchunked_data = ...
            subsasgn(unchunked_data,subsasgn_structure,unpadded_chunk);
    end
end
end
