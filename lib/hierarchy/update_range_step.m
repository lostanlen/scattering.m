function zeroth_ranges = ...
    update_range_step(zeroth_ranges,log2_sampling,subscripts)
if iscell(zeroth_ranges)
    nNodes = numel(zeroth_ranges);
    for node = 1:nNodes
        % Recursive call
        zeroth_ranges{node} = ...
            update_range_step(zeroth_ranges{node},log2_sampling,subscripts);
    end
else
    zeroth_ranges(2,subscripts) = pow2(-log2_sampling);
end
end