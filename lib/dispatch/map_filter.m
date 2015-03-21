function y = map_filter(x_ft,filters,log2_resampling,bank_behavior)
if ~iscell(x_ft)
    %% Map gamma filtering across thetas
    nThetas = size(filters,2);
    colons = bank_behavior.colons;
    subscripts = bank_behavior.subscripts;
    if nThetas==1 && ~isfield(bank_behavior,'spiral')
        y = ifft_multiply(x_ft,filters,log2_resampling,colons,subscripts);
    else
        input_sizes = drop_trailing(size(x_ft));
        [output_sizes,subsasgn_structures,spiraled_sizes] = ...
            prepare_assignment(input_sizes,log2_resampling, ...
            bank_behavior,nThetas);
        output_sizes = output_sizes{1};
        subsasgn_structure = subsasgn_structures{1};
        y = zeros(output_sizes);
        for theta = 1:nThetas
            filter_struct = filters(theta);
            subsasgn_structure.subs{end} = theta;
            y = subsasgn(y,subsasgn_structure, ...
                ifft_multiply(x_ft,filter_struct,log2_resampling, ...
                colons,subscripts));
        end
        if ~isempty(spiraled_sizes)
            y = reshape(y,spiraled_sizes);
        end
    end
else
    %% Map gamma filtering across cells
    input_sizes = drop_trailing(size(x_ft));
    nCells = prod(input_sizes);
    vectorized_output = cell(nCells,1);
    if iscell(x_ft{1})
        for cell_index = 1:nCells
            vectorized_output{cell_index} = map_filter( ...
                x_ft{cell_index}(:),filters,log2_resampling,bank_behavior);
        end
    else
        nThetas = size(filters,2);
        colons = bank_behavior.colons;
        subscripts = bank_behavior.subscripts;
        if nThetas==1
            for cell_index = 1:nCells
                % TODO: implement prepare_assignment for blur here
                % (may be needed when blurring and spiraling on non-numeric input)
                vectorized_output{cell_index} = ...
                    ifft_multiply(x_ft{cell_index},filters, ...
                    log2_resampling,colons,subscripts);
            end
        else
            for cell_index = 1:nCells
                tensor_sizes = drop_trailing(size(x_ft{cell_index}));
                [output_sizes,subsasgn_structures] = ...
                    prepare_assignment(tensor_sizes,log2_resampling, ...
                    bank_behavior,nThetas);
                output_sizes = output_sizes{1};
                subsasgn_structure = subsasgn_structures{1};
                y = zeros(output_sizes);
                for theta = 1:nThetas
                    filter_struct = filters(theta);
                    subsasgn_structure.subs{end} = theta;
                    subsasgn(y,subsasgn_structure, ...
                        ifft_multiply(x_ft{cell_index},filter_struct, ...
                        log2_resampling,colons,subscripts));
                end
                vectorized_output{cell_index} = y;
            end
        end
    end
    y = reshape(vectorized_output,[input_sizes,1]);
end
