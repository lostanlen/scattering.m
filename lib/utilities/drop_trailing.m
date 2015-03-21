function dropped_sizes = drop_trailing(sizes,min_dimension)
if length(sizes)==2 && sizes(2)==1
    if sizes(1)==1
        dropped_sizes = [];
    else
        dropped_sizes = sizes(1);
    end
else
    dropped_sizes = sizes;
end
if nargin>1 && length(dropped_sizes)<min_dimension
    dropped_sizes = sizes(1:min_dimension);
end
end