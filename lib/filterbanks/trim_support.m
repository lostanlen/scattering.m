function [coefficients,start] = trim_support(coefficients,bank_spec)
if sum(size(coefficients)~=1)>1
    error('support trimming not ready for multidimensional signals');
end

%% Does not trim if threshold is negative
relative_threshold = bank_spec.trim_threshold;
if relative_threshold<=0
    start = 1;
    return;
end

%% Finds maximum absolute value
original_length = length(coefficients);
abs2_values = coefficients .* conj(coefficients);
[max_abs2,max_index] = max(abs2_values);
max_indices = find(abs2_values==max_abs2);
if length(max_indices)>1
    max_index = ...
        floor(mod(sum(max_indices),original_length)/length(max_indices));
end
absolute_threshold = max_abs2 * relative_threshold;

%% Shifts circularly the absolute values
shift_size = original_length/2 - max_index + 1;
signal_colons = substruct('()',replicate_colon(length(bank_spec.size)));
shifted_coefficients = ...
    fast_circshift(coefficients,shift_size,signal_colons);
shifted_abs2 = shifted_coefficients .* conj(shifted_coefficients);

%% Detects first and last non-negligible coefficient in shifted domain
first_detected_index = find(shifted_abs2>absolute_threshold,1);
last_detected_index = find(shifted_abs2>absolute_threshold,1,'last');

%% Trims coefficients to range
coefficients = shifted_coefficients(first_detected_index:last_detected_index);
start = first_detected_index + max_index - (original_length/2 + 1);
start = ...
    mod(start-1+original_length/2, original_length) - original_length/2 + 1;
end
