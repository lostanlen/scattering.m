function signal_support = get_signal_support(data,ranges,subscripts)
% Here, tail call may be simply optimized, so we do not need any recursion
zeroth_ranges = ranges{1+0};
while iscell(data)
    data = data{1};
    zeroth_ranges = zeroth_ranges{1};
end
signal_support = size(data,subscripts) .* zeroth_ranges(2,subscripts);
end