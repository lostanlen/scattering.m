function [padded_indices,conjugation_bools] = ...
    set_padded_indices(original_indices,original_bools,original_length, ...
    padded_length)
%% Setting of unpadded indices
padded_indices = zeros(1,padded_length);
padded_indices(1:original_length) = (1:original_length);
conjugation_bools = zeros(1,padded_length);
conjugation_bools(1:original_length) = zeros(1,original_length);

%% Settinf of first half of padded indices
nOriginal_indices = length(original_indices);
floor_half_difference = floor(padded_length-original_length)/2;
range = (original_length+1):(original_length+floor_half_difference);
source = mod(range-1,nOriginal_indices) + 1;
padded_indices(range) = original_indices(source);
conjugation_bools(range) = original_bools(source);

%% Setting of second half of padded indices
ceil_half_difference = ceil(padded_length-original_length)/2;
range = (1:ceil_half_difference);
source = mod(nOriginal_indices-range,nOriginal_indices) + 1;
destinations_upper_bound = original_length + floor_half_difference + 1;
destinations = padded_length:(-1):destinations_upper_bound;
padded_indices(destinations) = original_indices(source);
conjugation_bools(destinations) = original_bools(source);
end
