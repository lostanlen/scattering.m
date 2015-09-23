function coefficients = untrim_ft(filter,bank_spec)
original_sizes = bank_spec.size;
coefficients = zeros([original_sizes,1]);
if ~isempty(filter.ft_pos)
    coefficients(1 + (1:length(filter.ft_pos))) = ...
        filter.ft_pos;
end
if ~isempty(filter.ft_neg)
    coefficients(end + filter.ft_neglast + ((-length(filter.ft_neg)+1):0)) = ...
        filter.ft_neg;
end
end
