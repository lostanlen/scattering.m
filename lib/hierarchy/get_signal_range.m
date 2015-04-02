function signal_range = get_signal_range(zeroth_ranges,subscripts)
% Here, tail call may be simply optimized, so we do not need any recursion
while iscell(zeroth_ranges)
    zeroth_ranges = zeroth_ranges{1};
end
signal_range = zeroth_ranges(:,subscripts);
end