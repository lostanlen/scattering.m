function data_ft = dual_firstborn_blur(data,bank,ranges)
%% Deep map across levels
level_counter = length(ranges) - 1;
input_size = drop_trailing(size(data),1);
if level_counter>0
    nNodes = numel(data);
    data_ft = cell(nNodes,1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        data_ft{node} = dual_firstborn_blur(data{node},bank,ranges_node);
    end
    if length(input_size)>1
        data_ft = reshape(data_ft,input_size);
    end
    return
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
dual_phi = bank.dual_phi{support_index};

%% Definition of resampling factor
critical_log2_sampling = 1 - log2(bank.spec.T);
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_resampling = - (critical_log2_sampling + log2_oversampling);

%% Dual-blurring implementations
% Note that we only need to unspiral in the phi branch along gamma, since the
% psi branch along gamma will be unspiraled afterwards in
% dual_firstborn_scatter.
is_psi_along_gamma = isequal(ranges{1}(:,end),[1;1;2]);
is_unspiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'gamma') && ~is_psi_along_gamma;

%% []. Normal
% e.g. along time, gamma, 2d space, theta etc.
if ~is_unspiraled
    data_ft = multiply_fft(data,dual_phi,log2_resampling,colons,subscripts);
    return
end

%% S. unSpiraled
% e.g. along j
if is_unspiraled
    data_ft = multiply_fft(data,dual_phi,log2_resampling,colons,subscripts);
    output_size = size(data_ft);
    spiral_subscript = bank_behavior.spiral.subscript;
    unspiraled_size = [ ...
        output_size(1:(spiral_subscript-1)), ...
        output_size(spiral_subscript)*output_size(spiral_subscript+1), ...
        output_size((spiral_subscript+2):end)];
    data_ft = reshape(data_ft,unspiraled_size);
    return
end
end