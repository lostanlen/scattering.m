function U0 = initialize_U(tensor, first_bank)
bank_spec = first_bank.spec;
bank_behavior = first_bank.behavior;
tensor_size = size(tensor);
subscripts = bank_behavior.subscripts;
unpadded_signal_size = tensor_size(subscripts);
hop_signal_size = bank_spec.size - 2 * bank_spec.T;
if ~bank_spec.is_chunked
    U0 = initialize_variables_auto(tensor_size);
elseif isequal(subscripts,1) && unpadded_signal_size<=hop_signal_size
    padded_signal_size = bank_spec.size;
    padding_signal_size = padded_signal_size - unpadded_signal_size;
    if padding_signal_size>0
        padding_zeros = zeros([padding_signal_size,tensor_size(2:end)]);
        tensor = cat(1,tensor,padding_zeros);
    end
    tensor_size(1) = bank_spec.size;
    U0 = initialize_variables_auto(tensor_size);
    U0.variable_tree.time{1}.leaf.unpadded_size = unpadded_signal_size;
elseif isequal(subscripts,1) && unpadded_signal_size>hop_signal_size
    nChunks = ceil(unpadded_signal_size/hop_signal_size);
    padded_signal_size = nChunks * hop_signal_size;
    padding_signal_size = padded_signal_size - unpadded_signal_size;
    padding_zeros = zeros([padding_signal_size,tensor_size(2:end)]);
    tensor = cat(1,tensor,padding_zeros);
    chunked_tensor_size = ...
        drop_trailing([bank_spec.size,nChunks,tensor_size(2:end)]);
    chunked_tensor = zeros(chunked_tensor_size);
    
    % Special case: first chunk
    lhs_indices = (1+bank_spec.T):bank_spec.size;
    rhs_indices = 1:(bank_spec.size-bank_spec.T);
    chunked_tensor(lhs_indices,1,:) = tensor(rhs_indices,:);
    
    % General case
    offset = bank_spec.size - 2 * bank_spec.T + 1;
    for chunk_index = 2:(nChunks-1)
        chunk_start = offset + (chunk_index-2) * hop_signal_size;
        chunk_end = chunk_start + bank_spec.size - 1;
        chunked_tensor(:,chunk_index,:) = tensor(chunk_start:chunk_end,:);
    end
    
    % Special case: last chunk
    lhs_indices = 1:(bank_spec.size-bank_spec.T);
    rhs_indices = ((1-(bank_spec.size-bank_spec.T)):0) + padded_signal_size;
    chunked_tensor(lhs_indices,nChunks,:) = tensor(rhs_indices,:);
    
    tensor = chunked_tensor;
    if ismatrix(chunked_tensor)
        variable_names = {'time', 'chunk'};
    else
        variable_names = {'time', 'chunk', 'channel'};
    end
    U0 = initialize_variables_custom(chunked_tensor_size,variable_names);
    U0.variable_tree.time{1}.leaf.unpadded_size = unpadded_signal_size;
end

%% Data storage and unpadding tree initialization
U0.data = tensor;

%% Alphanumeric ordering of field names
U0 = orderfields(U0);
end
