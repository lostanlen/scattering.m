function periodized_tensor = periodize(tensor,subscripts,period)
if nargin<3
    period = 2;
end
tensor_sizes = size(tensor);
% If periodized dimension has already collapsed, return a copy of tensor
if length(tensor_sizes)<max(subscripts)
    periodized_tensor = tensor;
    return
end
signal_sizes = tensor_sizes(subscripts);
nSubscripts = length(subscripts);

%% Expanded sizes computation
expanded_sizes = zeros(1,ndims(tensor)+nSubscripts);
sorted_subscripts = sort(subscripts);
first_subscript = sorted_subscripts(1);
expanded_sizes(1:(first_subscript-1)) = ...
    tensor_sizes(1:(first_subscript-1));
expanded_sizes(first_subscript) = signal_sizes(1) / period;
% Wrapping the for loop inside an if statement is an easy speed gain
if nSubscripts>1
    for subscript_index = 1:nSubscripts-1
        this_subscript = sorted_subscripts(subscript_index);
        translated_subscript = this_subscript + subscript_index;
        expanded_sizes(translated_subscript) = period;
        next_subscript = sorted_subscripts(subscript_index+1);
        translated_next_subscript = next_subscript + subscript_index;
        expanded_sizes(translated_subscript+1: ...
            (translated_next_subscript-1)) = ...
            tensor_sizes(this_subscript+1:next_subscript-1);
        expanded_sizes(translated_next_subscript) = ...
            signal_sizes(subscript_index) / period;
    end
end
last_subscript = sorted_subscripts(end);
translated_last_subscript = last_subscript + nSubscripts;
expanded_sizes(translated_last_subscript) = period;
expanded_sizes((translated_last_subscript+1):end) = ...
    tensor_sizes((last_subscript+1):end);

%% Expansion
expanded_tensor = reshape(tensor,expanded_sizes);

%% Periodized sizes computation
downsampled_sizes = tensor_sizes;
for subscript_index = 1:nSubscripts
    subscript = subscripts(subscript_index);
    translated_subscript = subscript + subscript_index;
    expanded_tensor = sum(expanded_tensor,translated_subscript);
    downsampled_sizes(subscript) = signal_sizes(1) / period;
end
periodized_tensor = reshape(expanded_tensor,downsampled_sizes);
end
