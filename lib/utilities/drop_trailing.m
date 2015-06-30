function dropped_sizes = drop_trailing(sizes,min_dimension)
if nargin<2
    dropped_sizes = sizes(1:find(sizes~=1,1,'last'));
else
    dropped_sizes = sizes(1:max(find(sizes~=1,1,'last'),min_dimension));
end
end
