function data_ft = dual_firstborn_blur(data,bank,ranges,sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data),1);
if level_counter>0
    nNodes = numel(data);
    data_ft = cell(nNodes,1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data_ft{node},ranges_node] = ...
            dual_firstborn_blur(data{node},bank,ranges_node,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    if length(input_sizes)>1
        data_ft = reshape(data_ft,input_sizes);
    end
    return
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
dual_phi = bank.dual_phi{support_index};

%% Definition of resampling factor
critical_log2_sampling = 1 - log2(bank.spec.T);
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_resampling = - (critical_log2_sampling + log2_oversampling);

%% Assignment preparation and update of ranges
is_spiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'gamma');

if is_spiraled
    error('spiraling in dual_firstborn_blur not ready yet');
end

%% Dual-blurring implementations
if ~is_spiraled
    %% []. Normal
    data_ft = multiply_fft(data,dual_phi,log2_resampling,colons,subscripts);
else
    %% S. Spiraled
    data_ft = subsasgn(zeros(output_size),subsasgn_structure, ...
        multiply_fft(data,phi,log2_resampling,colons,subscripts));
    data_ft = reshape(data_ft,spiraled_size);
end
end