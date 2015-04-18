function y = map_ifft_multiply(x_ft,filter_struct,log2_resampling,bank_behavior)
if ~iscell(x_ft)
    %% Map gamma filtering across thetas
    colons = bank_behavior.colons;
    subscripts = bank_behavior.subscripts;
    y = ifft_multiply(x_ft,filter_struct,log2_resampling,colons,subscripts);
else
    %% Map gamma filtering across cells
    input_sizes = drop_trailing(size(x_ft));
    nCells = prod(input_sizes);
    y = cell(nCells,1);
    if iscell(x_ft{1})
        for cell_index = 1:nCells
            y{cell_index} = map_ifft_multiply( ...
                x_ft{cell_index},filter_struct,log2_resampling,bank_behavior);
        end
    else
        colons = bank_behavior.colons;
        subscripts = bank_behavior.subscripts;
        for cell_index = 1:nCells
            y{cell_index} = ...
                ifft_multiply(x_ft{cell_index},filter_struct, ...
                log2_resampling,colons,subscripts);
        end
    end
    if length(input_sizes)>1
        y = reshape(y,input_sizes);
    end
end
