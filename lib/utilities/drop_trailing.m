function dropped_sizes = drop_trailing(sizes,min_dimension)
if nargin<2
    last_nonsingleton = find(sizes~=1,1,'last');
    if isempty(last_nonsingleton)
        last_nonsingleton = 1;
    end
    dropped_sizes = sizes(1:last_nonsingleton);
else
    last_nonsingleton = find(sizes~=1,1,'last');
    if isempty(last_nonsingleton)
        last_nonsingleton = 1;
    end
    dropped_sizes = sizes(1:max(last_nonsingleton,min_dimension));
end
end
