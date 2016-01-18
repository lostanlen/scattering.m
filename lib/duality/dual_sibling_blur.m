function data_ft = dual_sibling_blur(data, invariant, ranges, sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data),1);
if level_counter>0
    nNodes = numel(data);
    data_ft = cell(nNodes,1);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges, node);
        [data_ft{node},ranges_node] = ...
            dual_sibling_blur(data{node}, invariant, ranges_node, sibling);
        ranges = set_ranges_node(ranges, ranges_node, node);
    end
    if length(input_sizes)>1
        data_ft = reshape(data_ft, input_sizes);
    end
    return
end
if length(input_sizes)>1
    error('multiple subscripts at sibling level not ready in dual_sibling_blur');
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = invariant.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data, ranges, subscripts);
support_index = log2(invariant.spec.size/signal_support) + 1;
dual_phi = invariant.dual_phi{support_index};

%% Selection of sibling indices ("gammas")
is_deepest = (sibling.level==1);
sibling_subscript = sibling.subscripts;
sibling_gamma_range = ranges{end}(:,sibling_subscript);
sibling_gammas = collect_range(sibling_gamma_range);
nSibling_gammas = length(sibling_gammas);

%% Definition of resampling factors
critical_log2_sampling = 1 - invariant.spec.J;
S_log2_oversampling = bank_behavior.S.log2_oversampling;
log2_sampling = critical_log2_sampling + S_log2_oversampling;
U_log2_oversampling = sibling.behavior.U.log2_oversampling;
sibling_log2_resolutions = [sibling.metas(sibling_gammas).log2_resolution].';
sibling_log2_samplings = min(sibling_log2_resolutions+U_log2_oversampling, 0);
log2_resamplings = sibling_log2_samplings - log2_sampling;

%% Dual-blurring implementations
data_ft = cell([input_sizes, 1]);
%% []. Normal
% e.g. after joint time-frequency scattering, scattered over gamma
% e.g. after spiral scattering
if ~is_deepest
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        data_ft{sibling_index} = map_multiply_fft(data{sibling_index}, ...
            dual_phi, log2_resampling, bank_behavior);
    end
end

%% D. Deepest
% e.g. after plain second-order scattering
% e.g. after joint-time frequency scattering, blurred over gamma
if is_deepest
    for sibling_index = 1:nSibling_gammas
        log2_resampling = log2_resamplings(sibling_index);
        data_ft{sibling_index} = multiply_fft( ...
            data{sibling_index}, dual_phi, log2_resampling, colons, subscripts);
    end
end
end