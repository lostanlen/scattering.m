function [data,ranges] = sibling_blur(data_ft,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - 2;
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
elseif level_counter==0 && ~isnumeric(data_ft)
    nCousins = prod(input_sizes);
end

%% Selection of signal-adapted support for the filter bank
signal_range = get_signal_range(ranges{1+0},bank.behavior.subscript);
signal_log2_support = nextpow2(min(signal_range(end,:)-signal_range(1,:)+1));
support_index = log2(bank.spec.size) - signal_log2_support + 1;
phi = bank.phi{support_index};

%% Definition of resampling factors
sibling_log2_samplings = [sibling.metas.log2_sampling];
critical_log2_sampling = 1 - bank.spec.J;
log2_oversampling = bank.behavior.S.log2_oversampling;
log2_sampling = log2_oversampling + critical_log2_sampling;
critical_log2_resamplings = critical_log2_sampling - sibling_log2_samplings;
log2_resamplings = log2_oversampling + critical_log2_resamplings;

%% Update of ranges at zeroth level (tensor level)
ranges{1+0} = update_range_step(ranges{1+0},log2_sampling,subscripts);

%% Update of ranges at first level (gamma level)


%% If data is multidimensional, reshape it to a matrix
% The rows are the sibling gammas (e.g. "gamma_1" or "gamma_2")
% The columns are the "cousins" (e.g. gammas across other variables)
% This happens in all multi-variable architectures
data_ft_sizes = drop_trailing(size(data_ft));
nData_dimensions = length(data_ft_sizes);
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=sibling.subscript);
    cousin_sizes = data_ft_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if sibling.subscript>1
        permuted_subscripts = [sibling.subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    nSibling_gammas = data_ft_sizes(sibling.subscript);
    data_ft = reshape(data_ft,[nSibling_gammas,nCousins]);
else
    nCousins = 1;
end

%% Initialization of output data
data = cell([nSibling_gammas,nCousins]);
nSibling_gammas = length(log2_resamplings);
bank_behavior = bank.behavior;

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
if nCousins>1
    data = reshape(data,[data_ft_sizes,1]);
end
end
