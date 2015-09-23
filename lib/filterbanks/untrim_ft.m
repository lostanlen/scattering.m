function coefficients = untrim_ft(filter,bank_spec)
original_sizes = bank_spec.size;
coefficients = zeros([original_sizes,1]);
coefficients(1 + (1:length(filter.posfirst))) = filter.pos;
coefficients(end + filter.neglast + ((-length(filter.neg)+1):0)) = filter.neg;
end
