function y_ft = map_multiply_fft(x,filter_struct,log2_resampling,bank_behavior)
if ~iscell(x)
    %% Map gamma filtering across thetas
    colons = bank_behavior.colons;
    subscripts = bank_behavior.subscripts;
    y_ft = multiply_fft(x,filter_struct,log2_resampling,colons,subscripts);
else
    %% Map gamma filtering across cells
    input_sizes = drop_trailing(size(x));
    nCells = prod(input_sizes);
    y_ft = cell(nCells,1);
    if iscell(x{1})
        for cell_index = 1:nCells
            y_ft{cell_index} = map_multiply_fft( ...
                x{cell_index},filter_struct,log2_resampling,bank_behavior);
        end
    else
        colons = bank_behavior.colons;
        subscripts = bank_behavior.subscripts;
        for cell_index = 1:nCells
            y_ft{cell_index} = ...
                multiply_fft(x{cell_index},filter_struct, ...
                log2_resampling,colons,subscripts);
        end
    end
    if length(input_sizes)>1
        y_ft = reshape(y_ft,input_sizes);
    end
end
