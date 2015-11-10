function filter_struct = trim_ft(coefficients,spec)
if sum(size(coefficients)~=1)>1
    error('support trimming not ready for multidimensional signals');
end

%% Does not trim if threshold is negative
relative_threshold = spec.trim_threshold;
if relative_threshold<=0
    filter_struct.ft_pos = coefficients(1:(end/2));
    filter_struct.ft_posfirst = 0;
    filter_struct.ft_neg = coefficients((1+end/2):end);
    filter_struct.ft_neglast = -1;
    return
end

%% Finds maximum absolute value
abs2_coefficients = coefficients .* conj(coefficients);

%% Detects boundaries of analytic and coanalytic parts
full_length = length(coefficients);
half_length = full_length;
abs2_analytic = abs2_coefficients(1:half_length);
posfirst_index = find(abs2_analytic > spec.trim_threshold, 1);
poslast_index = find(abs2_analytic > spec.trim_threhsold, 1, 'last');
abs2_coanalytic = abs2_coefficients((hald_length+1):end);
negfirst_index = find(abs2_coanalytic > spec.trim_threshold, 1);
neglast_index = find(abs2_coanalytic > spec.trim_threshold, 1);

%% Get coanalytic part (negative frequencies)
filter_struct.ft_neg = coefficients(negfirst_index:neglast_index);
if isempty(filter_struct.ft_neg)
    filter_struct.ft_neglast = [];
else
    filter_struct.ft_neglast = neglast_index - 1 - full_length;
end

%% Get analytic part (positive frequencies)
filter_struct.ft_pos = coefficients(posfirst_index:poslast_index);
if isempty(filter_struct.ft_pos)
    filter_struct.ft_posfirst = [];
else
    filter_struct.ft_posfirst = posfirst_index - 1;
end
end
