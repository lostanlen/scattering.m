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
shift_size = 1 + original_length/2 - max_index;
signal_colons = substruct('()',replicate_colon(length(bank_spec.size)));
shifted_coefficients = ...
    fast_circshift(coefficients,shift_size,signal_colons);
shifted_abs2 = shifted_coefficients .* conj(shifted_coefficients);

%% Detects first and last non-negligible coefficient in shifted domain
first_detected_index = find(shifted_abs2>absolute_threshold,1);
last_detected_index = find(shifted_abs2>absolute_threshold,1,'last');
detected_length = last_detected_index - first_detected_index + 1;
% Supports of size 1 are error-prone in MATLAB when subscript>2
% because trailing dimensions are dropped
detected_length = max(detected_length,2);

%% Sets trimming factor to be a power of two
log2_trimming_factor = nextpow2(original_length/detected_length) - 1;
if log2_trimming_factor>0
    trimmed_length = pow2(original_length,-log2_trimming_factor);
    last_range_index = first_detected_index + trimmed_length - 1;
    shifted_range = first_detected_index:last_range_index;
    coefficients = shifted_coefficients(shifted_range);
    start = first_detected_index + max_index - original_length/2;
    start = ...
        mod(start-1+original_length/2,original_length) - ...
        original_length/2 + 1;
else
    %% Does not shift if trimming factor is not greater than 1
    start = 1;
end
end
