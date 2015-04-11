function ranges_node = get_ranges_node(ranges,node)
% This is faster than a cellfun
ranges_node = cell(1,length(ranges)-1);
for layer_index = 1:(length(ranges)-1)
    ranges_node{layer_index} = ranges{layer_index}{node};
end
end