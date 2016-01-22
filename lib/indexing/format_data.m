function formatted_data = format_data(data, spatial_subscripts, zeroth_ranges)
%% Recursive call
if iscell(data)
    nCells = numel(data);
    formatted_cells = cell(nCells, 1);
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        ranges_cell = zeroth_ranges{cell_index};
        formatted_cells{cell_index} = ...
            format_data(data_cell, spatial_subscripts, ranges_cell);
    end
    formatted_data = [formatted_cells{:}];
    return
end

%% Unpadding of non-spatial variables
input_sizes = drop_trailing(size(data)) ;
nSubscripts = length(input_sizes);
spatial_subscript_bools = true(nSubscripts, 1);
unpadded_sizes = zeros(nSubscripts, 1);
subsref_structure.type = '()';
subsref_structure.subs = cell(nSubscripts, 1);
for subscript_index = 1:nSubscripts
    spatial_subscript_bools(subscript_index) = ...
        any(spatial_subscripts == subscript_index);
    range = zeroth_ranges(:, subscript_index);
    unpadded_sizes(subscript_index) = floor((range(3)-range(1)+1) / range(2));
    subsref_structure.subs{subscript_index} = 1:unpadded_sizes(subscript_index);
end
unpadded_data = subsref(data, subsref_structure);

%% Reshaping to time-feature matrix
spatial_sizes = unpadded_sizes(spatial_subscripts);
nonspatial_sizes = unpadded_sizes(~spatial_subscript_bools);
nFeatures = prod(nonspatial_sizes);
output_sizes = [prod(spatial_sizes), nFeatures];
formatted_data = reshape(unpadded_data, output_sizes);
end