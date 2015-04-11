function [data,ranges] = sibling_blur(data_ft,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    nNodes = numel(data_ft);
    data = cell(nNodes,1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            sibling_blur(data_ft{node},bank,ranges_node,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    if length(input_sizes)>1
        data = reshape(data,input_sizes);
    end
    return;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
signal_log2_support =
support_index = log2(bank.spec.size/get_signal_support(data_ft,subscripts);) + 1;
phi = bank.phi{support_index};

%% Definition of resampling factors
sibling_gammas = collect_range(ranges{end}(:,sibling.subscripts));
log2_resolutions = [sibling.metas(sibling_gammas).log2_resolution];
sibling_log2_oversampling = sibling.behavior.U.log2_oversampling;
log2_factor = sibling.behavior.sibling_mask_factor;
sibling_log2_samplings = ...
    min(log2_resolutions+sibling_log2_oversampling,log2_factor);
critical_log2_sampling = 1 - bank.spec.J;
log2_sampling = sibling_log2_oversampling + critical_log2_sampling;
critical_log2_resamplings = critical_log2_sampling - sibling_log2_samplings;
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_resamplings = log2_oversampling + critical_log2_resamplings;

%% Update of ranges at zeroth level (tensor level)
ranges{1+0} = update_range_step(ranges{1+0},log2_sampling,subscripts);

%% If data is multidimensional, reshape it to a matrix
% The rows are the sibling gammas (e.g. "gamma_1" or "gamma_2")
% The columns are the "cousins" (e.g. gammas across other variables)
% This happens in all multi-variable architectures
nData_dimensions = length(input_sizes);
cousin_subscripts = find((1:nData_dimensions)~=sibling.subscripts);
nCousins = prod(cousin_subscripts);
if sibling.subscripts>1
    permuted_subscripts = [sibling.subscripts,cousin_subscripts];
    data_ft = permute(data_ft,permuted_subscripts);
end
nSibling_gammas = input_sizes(sibling.subscripts);
data_ft = reshape(data_ft,[nSibling_gammas,nCousins]);

%% Initialization of output data
data = cell([nSibling_gammas,nCousins]);

%% Blurring implementation
% This loop can be parallelized
for cousin_index = 1:nCousins
    data_slice = cell(nSibling_gammas,1);
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        local_data_ft = data_ft{sibling_index,cousin_index};
        data_slice{sibling_index} = map_filter(local_data_ft,phi, ...
            log2_resampling,bank_behavior);
    end
    data(:,cousin_index) = data_slice;
end

%% Reshaping of linear cell array back to its original multidimensional format
if nData_dimensions>1
    data = reshape(data,[data_ft_sizes,1]);
end
end
