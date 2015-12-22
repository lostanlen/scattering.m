function data_ft = dual_firstborn_blur(data, invariant, ranges)
%% Deep map across levels
level_counter = length(ranges) - 1;
input_size = drop_trailing(size(data), 1);
if level_counter>0
    nNodes = numel(data);
    data_ft = cell(nNodes, 1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges, node);
        data_ft{node} = ...
            dual_firstborn_blur(data{node}, invariant, ranges_node);
    end
    if length(input_size)>1
        data_ft = reshape(data_ft, input_size);
    end
    return
end

%% Selection of signal-adapted support for the filter bank
invariant_behavior = invariant.behavior;
colons = invariant_behavior.colons;
subscripts = invariant_behavior.subscripts;
signal_support = get_signal_support(data, ranges, subscripts);
support_index = log2(invariant.spec.size/signal_support) + 1;
dual_phi = invariant.dual_phi{support_index};

%% Definition of resampling factor
critical_log2_sampling = 1 - log2(invariant.spec.T);
log2_oversampling = invariant_behavior.S.log2_oversampling;
log2_resampling = - (critical_log2_sampling + log2_oversampling);

%% Dual-blurring implementations
data_ft = multiply_fft(data, dual_phi, log2_resampling, colons, subscripts);
end