function dY_data = ...
    dU_times_Y_over_U(dU_data,Y_data,U_data,dU_ranges,Y_ranges)
%% Range intersection at top level
[~,dU_substruct,Y_substruct] = intersect_ranges(dU_ranges,Y_ranges);

%% Recursive product-and-quotient across levels
if length(dU_ranges)>1
    % Subscripted reference
    if any(cellfun(@isnumeric,dU_substruct))
        dU_data = subsref(dU_data,dU_substruct);
    end
    if any(cellfun(@isnumeric,Y_substruct))
        Y_data = subsref(Y_data,Y_substruct);
        U_data = subsref(U_data,Y_substruct);
    end
    
    % Output initialization
    dY_data = cell(size(dU_data));
    
    % Loop over nodes
    for node = 1:numel(dU_data)
        % Get respective ranges corresponding to node
        dU_ranges_node = get_ranges_node(dU_ranges,node);
        Y_ranges_node = get_ranges_node(Y_ranges,node);
        % Recursive call
        dY_data{node} = dU_times_Y_over_U( ...
            dU_data{node},Y_data{node},U_data{node}, ...
            dU_ranges_node,Y_ranges_node);
    end
else
    %% Subscripted reference and pointwise substraction
    dY_data = subsref(dU_data,dU_substruct) .* ...
        (subsref(Y_data,Y_substruct) ./ subsref(U_data,Y_substruct));
end
end