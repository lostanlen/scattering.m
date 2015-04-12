function disp_sizes(cell_array)
%%
if ~ismatrix(cell_array)
    disp(cell_array);
    return;
end
[nRows,nColumns] = size(cell_array);
nSubscripts = cellfun(@ndims,cell_array);
if ~all(nSubscripts(:)==nSubscripts(1))
    disp(cell_array);
    return;
end
nSubscripts = nSubscripts(1);
sizes = cellfun(@size,cell_array,'UniformOutput',false);
classes = cellfun(@class,cell_array,'UniformOutput',false);
nDigits_handle = @(x) 1 + floor(log10(x));
nDigits_cell = cellfun(nDigits_handle,sizes,'UniformOutput',false);
tensor_sizes = [nRows,nColumns,nSubscripts];
nDigits_tensor = zeros(tensor_sizes);
for row = 1:nRows
    for column = 1:nColumns
        nDigits_tensor(row,column,:) = nDigits_cell{row,column};
    end
end
max_nDigits = max(nDigits_tensor,[],1);
strings = cell(nRows,nColumns);
for row = 1:nRows
    for column = 1:nColumns
        cell_sizes = sizes{row,column};
        nCharacters = squeeze(max_nDigits(1,column,:));
        initial_small_string = num2str(cell_sizes(1));
        nBlanks = nCharacters(1) - length(initial_small_string);
        big_string = ['[',blanks(nBlanks),initial_small_string];
        for subscript = 2:nSubscripts
            number = cell_sizes(subscript);
            small_string = num2str(number);
            nBlanks = nCharacters(subscript) - length(small_string);
            big_string = ...
                cat(2,big_string,'x',blanks(nBlanks),small_string);
        end
        strings{row,column} = [big_string,' ',classes{row,column},']'];
    end
end
disp(strings);
end

