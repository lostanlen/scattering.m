function y = ifft_multiply(x_ft,filter,log2_resampling,colons,subscripts)
if length(subscripts)>1
    error('Fourier-based filtering not ready in dimension >1');
end
input_sizes = size(x_ft);

%% Definition of positive range
x_sizes = input_sizes(subscripts);
x_start = - x_sizes/2;
x_end = x_sizes/2 - 1;

y_sizes = pow2(x_sizes,log2_resampling);
y_start = - y_sizes/2;
y_end = y_sizes/2 - 1;

filter_pos_end = filter.ft_posfirst + length(filter.ft_pos) - 1;
pos_range_start = filter.ft_posfirst;
pos_range_end = min(min(x_end, filter_pos_end), y_end);

%% Definition of negative range
filter_neg_start = filter.ft_neglast - length(filter.ft_neg) + 1;
neg_range_start = max(max(x_start, filter_neg_start), y_start);
neg_range_end = filter.ft_neglast;

%% Trimming of x
pos_x_range = (1+pos_range_start):(1+pos_range_end);
colons.subs{subscripts} = pos_x_range;
pos_x_ft = subsref(x_ft, colons);
neg_x_range = (1+x_sizes+neg_range_start):(1+x_sizes+neg_range_end);
colons.subs{subscripts} = neg_x_range;
neg_x_ft = subsref(x_ft, colons);

%% Trimming of filter
pos_filter_range = ...
    (1+pos_range_start-filter.ft_posfirst):(1+pos_range_end-filter.ft_posfirst);
colons.subs{subscripts} = pos_filter_range;
pos_filter_ft = subsref(filter.ft_pos, colons);

neg_filter_range = ...
    (1+neg_range_start-filter_neg_start):(1+neg_range_end-filter_neg_start);
colons.subs{subscripts} = neg_filter_range;
neg_filter_ft = subsref(filter.ft_neg, colons);

%% Product between non-negligible Fourier coefficients of x_ft and filter
pos_y_ft = bsxfun(@times, pos_x_ft, pos_filter_ft);
neg_y_ft = bsxfun(@times, neg_x_ft, neg_filter_ft);

%% Assignment of product to zero-allocated y_ft
y_tensor_sizes = size(x_ft);
y_tensor_sizes(subscripts) = y_sizes;
y = zeros(y_tensor_sizes);

pos_y_range = (1+pos_range_start):(1+pos_range_end);
colons.subs{subscripts} = pos_y_range;
y = subsasgn(y, colons,  pos_y_ft);

neg_y_range = (1+neg_range_start+y_sizes):(1+neg_range_end+y_sizes);
colons.subs{subscripts} = neg_y_range;
y = subsasgn(y, colons, neg_y_ft);

%% In-place inverse Fourier transform
for subscript = subscripts
    y = ifft(y,[],subscript);
end
end