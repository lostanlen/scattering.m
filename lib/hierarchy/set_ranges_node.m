function ranges = set_ranges_node(ranges,ranges_node,node)
nLevels = length(ranges);
ranges{end-1}{node} = ranges_node{end};
for level = 2:(nLevels-1)
    ranges{end-level}{node} = ranges_node{end-level+1};
end
end