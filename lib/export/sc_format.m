function [formatted_S,formatted_layers] = sc_format(S, spatial_subscripts, layers)
nLayers = length(S);
if nargin<3
    layers = (2:nLayers);
end
if nargin<2
    spatial_subscripts = 1;
end

formatted_layers = cell(length(layers),1);
for layer_index = layers
    formatted_layers{layer_index} = ...
        format_layer(S{layer_index}, spatial_subscripts);
end

formatted_S = [formatted_layers{:}].';
end

function formatted_layer = format_layer(layer_S, spatial_subscripts)
if iscell(layer_S)
    nCells = numel(layer_S);
    formatted_cells = cell(nCells,1);
    for cell_index = 1:nCells
        cell_S = layer_S{cell_index};
        if ~isempty(cell_S)
            formatted_cells{cell_index} = ...
                format_layer(cell_S, spatial_subscripts);
        end
    end
    formatted_layer = [formatted_cells{:}];
    return
end

formatted_layer = format_data(layer_S.data, spatial_subscripts, layer_S.ranges{1+0});
end

function formatted_data = format_data(data, spatial_subscripts, zeroth_ranges)
%% Recursive call
if iscell(data)
    nCells = numel(data);
    formatted_cells = cell(nCells,1);
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        ranges_cell = zeroth_ranges{cell_index};
        formatted_cells{cell_index} = ...
            format_data(data_cell,spatial_subscripts,ranges_cell);
    end
    formatted_data = [formatted_cells{:}];
    return
end

%% Unpadding
input_sizes = size(data);
nSubscripts = length(input_sizes);
spatial_subscript_bools = true(nSubscripts,1);
unpadded_sizes = zeros(nSubscripts,1);
subsref_structure = substruct('()',cell(nSubscripts,1));
for subscript_index = 1:nSubscripts
    spatial_subscript_bools(subscript_index) = ...
        any(spatial_subscripts == subscript_index);
    range = zeroth_ranges(:,subscript_index);
    unpadded_sizes(subscript_index) = ceil((range(3)-range(1)+1) / range(2));
    subsref_structure.subs{subscript_index} = 1:unpadded_sizes(subscript_index);
end
unpadded_data = subsref(data,subsref_structure);

%% Reshaping to time-feature matrix
spatial_sizes = unpadded_sizes(spatial_subscripts);
nonspatial_sizes = unpadded_sizes(~spatial_subscript_bools);
output_sizes = [prod(spatial_sizes), prod(nonspatial_sizes)];
formatted_data = reshape(unpadded_data, output_sizes);
end
