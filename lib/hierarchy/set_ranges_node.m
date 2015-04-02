function ranges = set_ranges_node(ranges,ranges_node,node)
for level = 0:(length(ranges_node)-1)
    ranges{end-level}{node} = ranges_node{end-level}{node};
end
end