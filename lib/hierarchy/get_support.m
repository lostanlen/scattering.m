function support = get_support(data,subscripts)
if iscell(data)
    support = get_support(data{1},subscripts);
else
    data_sizes = size(data);
    support = data_sizes(subscripts);
end
