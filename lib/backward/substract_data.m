function [difference_data,difference_ranges] = substract_data( ...
    minuend_data,subtrahend_data,minuend_ranges,subtrahend_ranges)
%% Range intersection at top level
difference_ranges = cell(size(minuend_ranges));
[difference_ranges{end},minuend_substruct,subtrahend_substruct] = ...
    intersect_ranges(minuend_ranges{end},subtrahend_ranges{end});

%% Recursive substraction across levels
if length(minuend_ranges)>1
    % Subscripted reference
    if any(cellfun(@isnumeric,minuend_substruct.subs))
        minuend_data = subsref(minuend_data,minuend_substruct);
    end
    if any(cellfun(@isnumeric,subtrahend_substruct.subs))
        subtrahend_data = subsref(subtrahend_data,subtrahend_substruct);
    end
    
    % Difference initialization
    difference_data = cell(size(minuend_data));
    
    % Loop over nodes
    for node = 1:numel(minuend_data)
        % Get respective ranges corresponding to node in minuend and subtrahend
        minuend_ranges_node = get_ranges_node(minuend_ranges,node);
        subtrahend_ranges_node = get_ranges_node(subtrahend_ranges,node);
        % Recursive call
        [difference_data{node},difference_ranges_node] = substract_data( ...
            minuend_data{node},subtrahend_data{node}, ...
            minuend_ranges_node,subtrahend_ranges_node);
        % Set ranges corresponding to node in difference
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