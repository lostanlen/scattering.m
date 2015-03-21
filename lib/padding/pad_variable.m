function [padded_indices,conjugation_bools] = ...
    pad_variable(tensor_sizes,variable)
%% Initialization
padded_sizes = variable.original_sizes;
subscripts = variable.subscripts;
padding = variable.padding;
nSubscripts = length(subscripts);
padded_indices = cell(1,nSubscripts);
conjugation_bools = cell(1,nSubscripts);

if padding.is_symmetric
%% Symmetric padding
    for subscript_index = 1:nSubscripts
        subscript = subscripts(subscript_index);
        original_length = tensor_sizes(subscript);
        padded_length = padded_sizes(subscript);
        original_indices = [1:original_length, original_length:-1:1];
        original_bools = ...
            [false(1,original_length), ones(1,original_length)];
        [padded_indices{subscript_index}, ...
            conjugation_bools{subscript_index}] = ...
            set_padded_indices(original_indices,original_bools, ...
            original_length,padded_length);
    end
    
elseif padding.is_periodic
%% Periodic padding
    for subscript_index = 1:nSubscripts
        subscript = subscripts(subscript_index);
        original_length = tensor_sizes(subscript);
        padded_length = padded_sizes(subscript);
        original_indices = 1:original_length;
        original_bools = false(1,original_length);
        [padded_indices{subscript_index}, ...
            conjugation_bools{subscript_index}] = ...
            set_padded_indices(original_indices,original_bools, ...
            original_length,padded_length);
    end

elseif padding.is_zero
%% Zero padding
    for subscript_index = 1:nSubscripts
        subscript = subscripts(subscript_index);
        original_length = tensor_sizes(subscript);
        padded_length = padded_sizes(subscript);
        padded_indices{subscript_index} = 1:original_length;
        conjugation_bools{subscript_index} = false(1,padded_length);
    end
end
end
