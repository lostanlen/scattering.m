function refs = generate_refs(data, spatial_subscripts, zeroth_ranges)
%% Deep map across cells
if iscell(data)
    input_sizes = drop_trailing(size(data));
    nSubscripts = length(input_sizes);
    nCells = prod(input_sizes);
    cumprod_sizes = [1 cumprod(input_sizes)];
    ref_cells = cell(1, nCells);
    head_ref.type = '{}';
    for cell_index = 1:nCells
        data_cell = data{cell_index};
        zeroth_ranges_cell = zeroth_ranges{cell_index};
        ref_cell = ...
            generate_refs(data_cell, spatial_subscripts, zeroth_ranges_cell);
        temporary_index = cell_index;
        for subscript_index = nSubscripts:-1:1
            cumprod_size = cumprod_sizes(subscript_index);
            vi = rem(temporary_index-1, cumprod_size) + 1;
            vj = (temporary_index - vi)/cumprod_size + 1;
            head_ref.subs{subscript_index} = double(vj);
            temporary_index = vi;
        end
        nRefs = size(ref_cell, 2);
        head_row = repmat(head_ref, 1, nRefs);
        ref_cells{cell_index} = cat(1, head_row, ref_cell);
    end
    refs = [ref_cells{:}];
    return
end

%% Reference tensor
input_sizes = drop_trailing(size(data));
nSubscripts = length(input_sizes);
spatial_subscript_bools = true(nSubscripts,1);
unpadded_sizes = zeros(nSubscripts,1);
for subscript_index = 1:nSubscripts
    spatial_subscript_bools(subscript_index) = ...
        any(spatial_subscripts == subscript_index);
    range = zeroth_ranges(:,subscript_index);
    unpadded_sizes(subscript_index) = floor((range(3)-range(1)+1) / range(2));
end
nonspatial_unpadded_sizes = unpadded_sizes(~spatial_subscript_bools);
nInds = prod(nonspatial_unpadded_sizes);

%% Generic ind2sub
refs(1,1:nInds) = substruct('()',cell(nSubscripts,1));
for index = 1:nInds
    temporary_index = index;
    cumprod_sizes = [1 cumprod(nonspatial_unpadded_sizes(1:end-1))];
    nonspatial_subscript_index = length(nonspatial_unpadded_sizes);
    for subscript_index = nSubscripts:-1:1
        if spatial_subscript_bools(subscript_index)
            refs(index).subs{subscript_index} = ':';
        else
            cumprod_size = cumprod_sizes(nonspatial_subscript_index);
            vi = rem(temporary_index-1, cumprod_size) + 1;
            vj = (temporary_index - vi)/cumprod_size + 1;
            refs(index).subs{subscript_index} = double(vj);
            temporary_index = vi;
            nonspatial_subscript_index = nonspatial_subscript_index - 1;
        end
    end
end

end

