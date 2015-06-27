function U0 = initialize_U(tensor,first_bank,variable_names)
%%
bank_spec = first_bank.spec;
bank_behavior = first_bank.behavior;
chunk_signal_size = bank_spec.size;
tensor_size = size(tensor);
subscripts = bank_behavior.subscripts;
unpadded_signal_size = tensor_size(subscripts);
if isinf(bank_spec.max_scale)
    hop_signal_size = 2 * bank_spec.T;
else
    hop_signal_size = max_scale;
end
nChunks = ceil(unpadded_signal_size./hop_signal_size);
if nChunks>1 && isequal(subscripts,[1])
    padded_signal_size = nChunks * bank_spec.size;
    padding_signal_size = padded_signal_size - unpadded_signal_size;
    if any(padding_signal_size>0)
        padding_size = tensor_size;
        padding_size(subscripts) = padding_signal_size;
        padding_zeros = zeros(padding_size);
        tensor = cat(subscripts,tensor,padding_zeros);
    end
    if any(tensor_size((subscripts+1):end) ~= 1)
        chunked_tensor_size = cat(2,tensor_size(1:(subscripts-1)), ...
            chunk_signal_size,nChunks,tensor_size((subscripts+1):end));
    else
        chunked_tensor_size = ...
            cat(2,tensor_size(1:(subscripts-1)),chunk_signal_size,nChunks);
    end
    tensor = reshape(tensor,chunked_tensor_size);
    if length(chunked_tensor_size)==2
        variable_names = {'time','chunk'};
    elseif length(chunked_tensor_size)==3
        variable_names = {'time','chunk','channel'};
    end
    U0 = initialize_variables_custom(chunked_tensor_size,variable_names);
elseif nargin<3
    %% Automatic variable inference (for 1D and 2D only)
    U0 = initialize_variables_auto(tensor_size);
else
    %% Custom pattern matching of variable names
    U0 = initialize_variables_custom(tensor_size,variable_names);
end

%% Data storage and unpadding tree initialization
U0.data = tensor;

%% Alphanumeric ordering of field names
U0 = orderfields(U0);
end
