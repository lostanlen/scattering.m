function zeroth_ranges_out = map_collapse_ranges(zeroth_ranges_in)
%% Cell-wise map
if iscell(zeroth_range_in)
    cell_sizes = size(zeroth_ranges_in);
    zeroth_ranges_out = cell(cell_sizes);
    nCells = prod(cell_sizes);
    for cell_index = 1:nCells
        zeroth_ranges_out{cell_index} = ...
            map_collapse_ranges(zeroth_ranges_in{cell_index});
    end
end

end