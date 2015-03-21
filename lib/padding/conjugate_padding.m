function conjugated = ...
    conjugate_padding(padded_tensor,variable,conjugation_bools)
%% Initialization
conjugated = padded_tensor;
subscripts = variable.subscripts;
nSubscripts = length(subscripts);
nTensor_dimensions = ndims(padded_tensor);
imaginary_part = imag(padded_tensor);
padded_sizes = variable.original_sizes;

%% Subscript loop
for subscript_index = 1:nSubscripts
    subscript = subscripts(subscript_index);
    bsxfun_sizes = ones(1,nTensor_dimensions);
    bsxfun_sizes(subscript) = padded_sizes(subscript);
    subscript_bools = conjugation_bools{subscript_index};
    bsxfun_bools = reshape(subscript_bools,bsxfun_sizes);
    subtrahend = 2i * bsxfun(@times,bsxfun_bools,imaginary_part);
    padded_tensor = padded_tensor - subtrahend;
end
end
