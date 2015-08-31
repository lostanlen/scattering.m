function [data,ranges] = nephew_scatter(data_ft,bank,ranges,sibling,uncle)
%% Deep map across levels
level_counter = length(ranges) - 1 - uncle.level;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    data = cell([input_sizes,1]);
    for node = 1:numel(data_ft)
        node_ranges = get_ranges_node(ranges,node);
        % Recursive call
        [data{node},ranges_node] = ...
            nephew_scatter(data_ft{node},bank,node_ranges,sibling,uncle);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return;
end

%% If data is multidimensional, reshaping to a matrix
uncle_subscript = uncle.subscripts;
nUncle_gammas = input_sizes(uncle_subscript);
nData_dimensions = length(input_sizes);
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=uncle_subscript);
    cousin_sizes = input_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if uncle.subscripts(1)>1
        permuted_subscripts = [uncle_subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    data_ft = transpose(reshape(data_ft,[nUncle_gammas,nCousins]));
else
    nCousins = 1;
end
data = cell(nUncle_gammas,nCousins);

%% Uncle upgrading in ranges
input_ranges = ranges;
if length(ranges)==2
    ranges = {ranges{1:(end-1)},{},ranges{end}};
end

%% Fallback to firstborn_scatter, secondborn_scatter, and sibling scatter
if nData_dimensions>1
    error('nephew_scatter for multiple variables at uncle level not ready yet');
end
for uncle_index = 1:nUncle_gammas
    ranges_node = get_ranges_node(input_ranges,uncle_index);
    if isempty(sibling)
        [data{uncle_index},ranges_node] = ...
            firstborn_scatter(data_ft{uncle_index},bank,ranges_node);
    elseif length(sibling.nSiblings)==1
        [data{uncle_index},ranges_node] = ...
            secondborn_scatter(data_ft{uncle_index},bank,ranges_node,sibling);
    else
        [data{uncle_index},ranges_node] = ...
            sibling_scatter(data_ft{uncle_index},bank,ranges_node,sibling);
    end
    ranges = set_ranges_node(ranges,ranges_node,uncle_index);
end
end