function zeroth_ranges = map_collapse_ranges(zeroth_ranges, subscripts)
%% Cell-wise map
if iscell(zeroth_ranges)
    nCells = numel(zeroth_ranges);
    for cell_index = 1:nCells
        zeroth_ranges{cell_index} = ...
            map_collapse_ranges(zeroth_ranges{cell_index}, subscripts);
    end
    return
end

%% Tail call
zeroth_ranges(2, subscripts) = 1;
end