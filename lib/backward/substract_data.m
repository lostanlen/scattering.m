function [difference_data,difference_ranges] = substract_data( ...
    minuend_data,minuend_ranges,subtrahend_data,subtrahend_ranges)
%% Range intersection at top level
difference_ranges = cell(size(minuend_ranges));
[difference_ranges{end},minuend_substruct,subtrahend_substruct] = ...
    intersect_ranges(minuend_ranges{end},subtrahend_ranges{end});

%%
if length(minuend_ranges)>1
    minuend_data = subsref(minuend_data,minuend_substruct);
    subtrahend_data = subsref(subtrahend_data,subtrahend_substruct);
    difference_data = cell(size(minuend_data));
    for node = 1:numel(minuend_data)
        minuend_ranges_node = get_ranges_node(minuend_ranges,node);
        subtrahend_ranges_node = get_ranges_node(subtrahend_ranges,node);
        [difference_data{node},difference_ranges_node] = substract_data( ...
            minuend_data{node},minuend_ranges_node, ...
            subtrahend_data{node},subtrahend_ranges_node);
        difference_ranges = ...
            set_ranges_node(difference_ranges,difference_ranges_node,node);
    end
else
    %% Subscripted reference and pointwise substraction
    difference_data = ...
        subsref(minuend_data,minuend_substruct) - ...
        subsref(subtrahend_data,minuend_substruct);
end
end