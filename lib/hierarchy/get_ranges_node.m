function ranges_node = get_ranges_node(ranges,node)
ranges_node = cellfun(@(x) x{node},ranges(1:end-1),'UniformOutput',false);
end