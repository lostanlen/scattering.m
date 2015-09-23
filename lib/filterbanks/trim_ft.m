function filter_struct = trim_ft(coefficients,bank_spec)
if sum(size(coefficients)~=1)>1
    error('support trimming not ready for multidimensional signals');
end

%% Does not trim if threshold is negative
relative_threshold = bank_spec.trim_threshold;
if relative_threshold<=0
    filter_struct.ft_pos = coefficients(2:(end/2));
    filter_struct.ft_posfirst = 1;
    filter_struct.ft_neg = coefficients((1+end/2):end);
    filter_struct.ft_neglast = -1;
    return
end

%% Finds maximum absolute value
abs2_coefficients = coefficients .* conj(coefficients);

%% Detects first and last non-negligible coefficient in shifted domain
first_detected_index = ...
    find(abs2_coefficients>bank_spec.trim_threshold, 1);
last_detected_index = ...
    find(abs2_coefficients>bank_spec.trim_threshold, 1, 'last');

%% Get coanalytic part (negative frequencies)
full_length = length(coefficients);
half_length = full_length / 2;
filter_struct.ft_neg = coefficients((1+half_length):last_detected_index);
if isempty(filter_struct.ft_neg)
    filter_struct.ft_neglast = [];
else
    filter_struct.ft_neglast = last_detected_index - 1 - full_length;
end

%% Get analytic part (positive frequencies)
filter_struct.ft_pos = coefficients(first_detected_index:(1+half_length-1));
if isempty(filter_struct.ft_pos)
    filter_struct.ft_posfirst = [];
else
    filter_struct.ft_posfirst = first_detected_index - 1;
end
end
