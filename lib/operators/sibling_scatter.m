function [data,ranges] = sibling_scatter(data_ft,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    nNodes = numel(data_ft);
    data = cell(nNodes,1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            sibling_scatter(data_ft{node},bank,ranges_node,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    if length(input_sizes)>1
        data = reshape(data,input_sizes);
    end
    return
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data_ft,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
psis = bank.psis{support_index};

%% 
% TODO: loop over gamma3
% TODO: define gamma2 range
% TODO: initialize data structure
% TODO: loop over gamma2
% TODO: define resampling factor
% TODO: 

%%

end