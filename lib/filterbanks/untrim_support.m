function coefficients = untrim_support(filter,bank_spec)
original_sizes = bank_spec.size;
coefficients = zeros([original_sizes,1]);
signal_dimension = length(original_sizes);
sizes = length(filter.ft);
mod_ranges = cell(1,signal_dimension);
for dimension_index = 1:signal_dimension
    start = filter.ft_start(1,dimension_index);
    nPoints = sizes(dimension_index);
    range = 1 + (start:(start+nPoints-1));
    original_nPoints = original_sizes(dimension_index);
    mod_ranges{signal_dimension} = 1 + mod(range-1,original_nPoints);
end
coefficients(mod_ranges{:}) = filter.ft;
end
