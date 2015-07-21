function unchunked_ranges = unchunk_ranges(zeroth_ranges,chunk_subscript)
%% Deep map across cells
if iscell(zeroth_ranges)
    nCells = numel(zeroth_ranges);
    unchunked_ranges = cell(size(zeroth_ranges));
    for cell_index = 1:nCells
        zeroth_ranges_cell = zeroth_ranges{cell_index};
        unchunked_ranges{cell_index} = ...
            unchunk_ranges(zeroth_ranges_cell,chunk_subscript);
    end
    return
end
%% Unchunking
if ~isequal(chunk_subscript,2)
    error('Unchunking for chunk subscript~=2 not ready');
end
spatial_range_end = zeroth_ranges(3,1) * zeroth_ranges(3,2) / 2;
unchunked_spatial_range = [zeroth_ranges(1:2,1);spatial_range_end];
unchunked_ranges = horzcat(unchunked_spatial_range,zeroth_ranges(:,3:end));
end