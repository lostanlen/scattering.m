function [data,ranges] = secondborn_blur(data_ft,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    nNodes = numel(data_ft);
    data = cell([input_sizes,1]);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            secondborn_blur(data_ft{node},bank,ranges_node,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
signal_range = get_signal_range(ranges{1+0},subscripts);
signal_log2_support = nextpow2(min(signal_range(end,:)-signal_range(1,:)+1));
support_index = log2(bank.spec.size) - signal_log2_support + 1;
phi = bank.phi{support_index};

%% Definition of resampling factors
sibling_log2_samplings = - log2(cellfun(@(x) x(2,subscripts),ranges{1+0}));
critical_log2_sampling = 1 - bank.spec.J;
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_sampling = log2_oversampling + critical_log2_sampling;
critical_log2_resamplings = critical_log2_sampling - sibling_log2_samplings;
log2_resamplings = log2_oversampling + critical_log2_resamplings;

%% If data is multidimensional, reshaping to a 2d cell array
% The rows are the sibling gammas ("gamma_1")
% The columns are the "cousins" (e.g. gammas across other variables)
% This happens in all multi-variable architectures
nData_dimensions = length(input_sizes);
nSibling_gammas = length(log2_resamplings);
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=sibling.subscript);
    cousin_sizes = input_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if sibling.subscript>1
        permuted_subscripts = [sibling.subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    nSibling_gammas = input_sizes(sibling.subscript);
    data_ft = reshape(data_ft,[nSibling_gammas,nCousins]);
else
    nCousins = 1;
end

%% Update of ranges at zeroth level (tensor level)
sibling_subscript = sibling.subscripts;
if isfield(bank_behavior,'gamma_padding_length');
    gamma_padding_length = bank_behavior.gamma_padding_length;
    nPadded_gammas = pow2(nextpow2(nSibling_gammas + gamma_padding_length));
else
    nPadded_gammas = nSibling_gammas;
end
ranges{1+0} = cat(2,ranges{1+0}{1},ranges{1+1}(:,sibling_subscript));
ranges{1+0}(3,end) = ranges{1+0}(1,end) + (nPadded_gammas-1);
ranges{1+0}(2,subscripts) = pow2(-log2_sampling);

%% Update of ranges at first level (gamma level)
ranges{1+1}(:,sibling_subscript) = [];
if isempty(ranges{1+1})
    ranges = ranges(1+0);
end

%% Initialization
ref_colons = bank_behavior.colons;
data = cell([nCousins,1]);
first_input_sizes = drop_trailing(size(data_ft{1}));
nInput_dimensions = length(first_input_sizes);
asgn_colons.type = '()';
asgn_colons.subs = replicate_colon(nInput_dimensions+1);
tensor_sizes = [first_input_sizes, nPadded_gammas];
tensor_sizes(subscripts) = bank.spec.size * pow2(log2_sampling);
tensor_sizes(end) = nPadded_gammas;
local_subsasgn_structure = asgn_colons;
local_tensor = zeros(tensor_sizes);

%% Blurring implementation
% This loop can be parallelized
for cousin_index = 1:nCousins
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        local_data_ft = data_ft{sibling_index,cousin_index};
        local_subsasgn_structure.subs{end} = sibling_index;
        local_tensor = subsasgn(local_tensor, ...
            local_subsasgn_structure, ...
            ifft_multiply(local_data_ft,phi, ...
            log2_resampling,ref_colons,subscripts));
    end
    data{cousin_index} = local_tensor;
end

%% Reshaping or downgrading if required
if nCousins>1
    data = reshape(data,[input_sizes,1]);
else
    data = data{1};
end
end
