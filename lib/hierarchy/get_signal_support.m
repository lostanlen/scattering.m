function signal_range = get_signal_support(data,subscripts)
% Here, tail call may be simply optimized, so we do not need any recursion
while iscell(data)
    data = data{1};
end
signal_range = min(size(data,subscripts));
end