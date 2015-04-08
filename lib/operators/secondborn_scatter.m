function [data,ranges] = secondborn_scatter(data_ft,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data_ft));
if level_counter>0
    data = cell([input_sizes,1]);
    for node = 1:numel(data_ft)
        % Recursive call
        node_ranges = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            secondborn_scatter(data_ft{node},bank,node_ranges,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return;
elseif level_counter==0
    nCousins = prod(input_sizes);
    data_ft = reshape(data_ft,[nCousins,1]);
else
    nCousins = 1;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
signal_range = get_signal_range(ranges{1+0},subscripts);
signal_log2_support = nextpow2(min(signal_range(end,:)-signal_range(1,:)+1));
support_index = log2(bank.spec.size) - signal_log2_support + 1;
psis = bank.psis{support_index};

%% Selection of filter indices ("gammas")
sibling_gammas = collect_range(sibling.behavior.gamma_bounds);
sibling_bandwidths = [sibling.metas(sibling_gammas).bandwidth];
sibling_mask_factor = bank_behavior.sibling_mask_factor;
bank_metas = bank.metas;
nGammas = length(bank_metas);
for gamma = nGammas:-1:1
    resolution = bank_metas(gamma).resolution;
    max_sibling_gamma_index = ...
        find(resolution < sibling_mask_factor*sibling_bandwidths,1,'last');
    if ~isempty(max_sibling_gamma_index)
        max_sibling_gamma = sibling_gammas(max_sibling_gamma_index);
        bank.metas(gamma).max_sibling_gamma = max_sibling_gamma;
        nFilters_per_octave = sibling.spec.nFilters_per_octave;
        bank.metas(gamma).max_sibling_j = ...
            1 + floor((max_sibling_gamma-1) / nFilters_per_octave);
    else
        break;
    end
end
gamma_bounds = bank_behavior.gamma_bounds;
gamma_range = [max(gamma_bounds(1),1+gamma),1,min(gamma_bounds(2),nGammas)].';
sibling_log2_samplings = - log2(cellfun(@(x) x(2,subscripts),ranges{1+0}));
log2_oversampling = bank_behavior.U.log2_oversampling;
log2_factor = ceil(log2(sibling_mask_factor));
gammas = collect_range(gamma_range);
nEnabled_gammas = length(gammas);
if nEnabled_gammas<1
    data = [];
    return;
end

%% Definition of resampling factors
log2_samplings = zeros(nEnabled_gammas,1);
log2_resamplings = cell(nEnabled_gammas,1);
for enabled_index = 1:nEnabled_gammas
    gamma = gammas(enabled_index);
    enabled_meta = bank.metas(gamma);
    max_sibling_gamma = enabled_meta.max_sibling_gamma;
    nUnmasked_indices = find(sibling_gammas<=max_sibling_gamma,1,'last');
    log2_resolution = enabled_meta.log2_resolution;
    unbounded_log2_sampling = log2_resolution + log2_oversampling;
    log2_samplings(enabled_index) = min(unbounded_log2_sampling,log2_factor);
    bank.metas(gamma).log2_sampling = log2_samplings(enabled_index);
    log2_resamplings{enabled_index} = log2_samplings(enabled_index) -  ...
        sibling_log2_samplings(1:nUnmasked_indices);
end

%% Data structure initialization
data = cell(nEnabled_gammas,nCousins);
ref_colons = bank.behavior.colons;
asgn_colons.type = '()';
first_input_sizes = drop_trailing(size(data_ft{1}));
tensor_sizes = [first_input_sizes,2,bank.spec.nThetas];
nInput_dimensions = length(first_input_sizes);
downgraded_sibling_subscript = nInput_dimensions + 1;
subscripts = bank.behavior.subscripts;
signal_sizes = bank.spec.size;
is_sibling_padded = isfield(bank.behavior,'gamma_padding_length');
nData_dimensions = length(input_sizes);
sibling_subscript = sibling.subscripts;

%% If data is multidimensional, reshape it to a matrix
% The rows are the sibling gammas ("gamma_1")
% The columns are the "cousins" (e.g. gammas across other variables)
% This happens e.g. for videos
if nData_dimensions>1
    cousin_subscripts = find((1:nData_dimensions)~=sibling_subscript);
    cousin_sizes = data_ft_sizes(cousin_subscripts);
    nCousins = prod(cousin_sizes);
    if sibling_subscript>1
        permuted_subscripts = [sibling_subscript,cousin_subscripts];
        data_ft = permute(data_ft,permuted_subscripts);
    end
    nSibling_gammas = data_ft_sizes(sibling_subscript);
    data_ft = reshape(data_ft,[nSibling_gammas,nCousins]);
end

%% Update of ranges at zeroth level (tensor level)
input_zeroth_range = ranges{1+0}{1};
output_zeroth_range = ...
    cat(2,input_zeroth_range,zeros(3,1+(bank.spec.nThetas>1)));
ranges{1+0} = cell(nEnabled_gammas,1);
for enabled_index = 1:nEnabled_gammas
    step = pow2(-log2_samplings(enabled_index));
    output_zeroth_range(2,subscripts) = step;
    gamma = gammas(enabled_index);
    min_sibling_gamma = ranges{1+1}(1,sibling_subscript);
    max_sibling_gamma = min(ranges{1+1}(3,sibling_subscript), ...
        bank.metas(gamma).max_sibling_gamma);
    if isfield(bank_behavior,'gamma_padding_length');
        max_sibling_gamma = min_sibling + ...
            pow2(nextpow2((max_sibling_gamma-min_sibling_gamma + 1 + ...
            bank_behavior.gamma_padding_length)));
    end
    output_zeroth_range(:,nData_dimensions+1) = ...
        [min_sibling_gamma,1,max_sibling_gamma].';
    if bank.spec.nThetas>1
        output_zeroth_range(:,end) = [1,1,bank.spec.nThetas].';
    end
    ranges{1+0}{enabled_index} = output_zeroth_range;
end

%% Update of ranges at first level (gamma level)
ranges{1+1}(:,sibling_subscript) = [];
ranges{1+1} = cat(2,ranges{1+1},gamma_range);

%%
if bank.spec.nThetas==1
    %% Case when there is only one orientation (nThetas==1)
    asgn_colons.subs = replicate_colon(nInput_dimensions+1);
    data_slice = cell(1,nCousins);
    % This loop can be parallelized
    for enabled_index = 1:nEnabled_gammas
        % Inference of downsampled size for transformed variable
        local_log2_resamplings = log2_resamplings{enabled_index};
        nSibling_gammas = length(local_log2_resamplings);
        log2_sampling = log2_samplings(enabled_index);
        local_tensor_sizes = tensor_sizes;
        local_tensor_sizes(subscripts) = signal_sizes * pow2(log2_sampling);
        % Inference of padded size for downgraded sibling gamma_1
        if is_sibling_padded
            local_tensor_sizes(downgraded_sibling_subscript) = ...
                pow2(nextpow2(nSibling_gammas+ ...
                bank.behavior.gamma_padding_length));
        else
            local_tensor_sizes(downgraded_sibling_subscript) = ...
                nSibling_gammas;
        end
        % Initialization of input tensor, band-pass filter, and output slice
        local_tensor = zeros(local_tensor_sizes);
        local_psi = psis(enabled_index);
        local_subsasgn_structure = asgn_colons;
        local_data_slice = data_slice;
        % Computationally intensive loop
        for cousin_index = 1:nCousins
            for sibling_index = 1:nSibling_gammas
                log2_resampling = local_log2_resamplings(sibling_index);
                local_data_ft = data_ft{sibling_index,cousin_index};
                local_subsasgn_structure.subs{downgraded_sibling_subscript} = ...
                    sibling_index;
                local_tensor = subsasgn(local_tensor,local_subsasgn_structure, ...
                    ifft_multiply(local_data_ft,local_psi, ...
                    log2_resampling,ref_colons,subscripts));
            end
            local_data_slice{cousin_index} = local_tensor;
        end
        % Output storage
        data(enabled_index,:) = local_data_slice;
    end
else
    %% Case when there is more than one orientation (nThetas>1)
    asgn_colons.subs = replicate_colon(nInput_dimensions+2);
    % TODO: write loops when nThetas>1 with inlined map_gamma
    % This is needed e.g. for images
end

%% Reshaping of linear cell array back to its original multidimensional format
if nCousins>1
    if length(cousin_sizes)>1
        data = reshape(data,[nEnabled_gammas, cousin_sizes]);
    end
    if sibling_subscript>1
        inverse_permutation(permuted_subscripts) = 1:nData_dimensions;
        data = permute(data,inverse_permutation);
    end
end
end
