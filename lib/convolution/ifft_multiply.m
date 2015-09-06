function y = ifft_multiply(x_ft,filter_struct,log2_resampling,colons,subscripts)
if length(subscripts)>1
    error('Fourier-based filtering not ready in dimension >1');
end
input_sizes = size(x_ft);

%% Definition of positive range
x_sizes = input_sizes(subscripts);
x_start = - x_sizes/2 + 1;
x_end = x_sizes/2;

y_sizes = pow2(x_sizes,log2_resampling);
y_start = - y_sizes/2 + 1;
y_end = y_sizes/2;

filter_ft = filter_struct.ft;
filter_sizes = length(filter_ft);
filter_start = filter_struct.ft_start;
filter_end = filter_start + filter_sizes - 1;
filter_mod_end = mod(filter_end + x_sizes/2 - 1, x_sizes) - x_sizes/2 + 1;

pos_range_start = max(0,filter_start);
if filter_mod_end>0
    pos_range_end = min([x_end, filter_mod_end, y_end]);
else
    pos_range_end = min([x_end, y_end]);
end
pos_range = pos_range_start:pos_range_end;

%% Definition of negative range
neg_range_end = min(filter_mod_end, -1);
if filter_start<0
    neg_range_start = max([x_start, filter_start, y_start]);
elseif filter_mod_end<0
    neg_range_start = max([x_start, y_start]);
else
    neg_range_start = 1;
end
neg_range = neg_range_start:neg_range_end;

%% Trimming of x_ft if needed
pos_x_range = 1 + pos_range;
neg_x_range = 1 + x_sizes + neg_range;
x_range = cat(2,neg_x_range,pos_x_range);
colons.subs{subscripts} = x_range;
trimmed_x_ft = subsref(x_ft,colons);

%% Trimming of filter_ft if needed
pos_filter_range = pos_range - filter_start + 1;
neg_filter_range = mod(neg_range - filter_start + 1 - 1, x_sizes) + 1;
filter_range = cat(2,neg_filter_range,pos_filter_range);
colons.subs{subscripts} = filter_range;
trimmed_filter_ft = subsref(filter_ft,colons);

%% Product between non-negligible Fourier coefficients of x_ft and filter_ft
sub_y_ft = bsxfun(@times,trimmed_x_ft,trimmed_filter_ft);

%% Assignment of product to zero-allocated y_ft
y_tensor_sizes = size(x_ft);
y_tensor_sizes(subscripts) = y_sizes;
y = zeros(y_tensor_sizes);
neg_y_range = neg_x_range + y_sizes - x_sizes;
y_range = cat(2,neg_y_range,pos_x_range);
colons.subs{subscripts} = y_range;
y = subsasgn(y,colons,sub_y_ft);

%% In-place inverse Fourier transform
for subscript = subscripts
    y = ifft(y,[],subscript);
end
end