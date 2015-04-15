function data_ft = dual_firstborn_scatter(data,bank,ranges,data_ft,ranges_out)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_size = drop_trailing(size(data),1);
if level_counter>0
    error('level_counter>0 in dual_firstborn_scatter not ready');
end

%% Selection of signal-adapted support to the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
dual_psis = bank.dual_psis{support_index};

%% Dual-scattering implementations
gamma_range = ranges{end}(:,bank_behavior.gamma_subscript);
gammas = collect_range(gamma_range);
nGammas = length(gammas);
nThetas = size(dual_psis,2);
is_oriented = nThetas>1;
is_deepest = size(ranges{end},2)==1;

%% Definition of resampling factors
enabled_log2_samplings = [bank.metas(gammas).log2_resolution].';
log2_oversampling = bank_behavior.U.log2_oversampling;
enabled_log2_resamplings = - min(enabled_log2_samplings + log2_oversampling, 0);

%% Assignment preparation and update of ranges
is_unspiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'gamma');

if is_unspiraled
    error('unspiraling in dual_firstborn_scatter not ready yet');
end

%% D. Deepest
% e.g. dual-scattering along time
if is_deepest && ~is_oriented
    for gamma_index = 1:nGammas
        gamma = gammas(gamma_index);
        log2_resampling = enabled_log2_resamplings(gamma_index);
        data_ft = multiply_fft_inplace(data{gamma_index},dual_psis(gamma), ...
            log2_resampling,colons,subscripts,data_ft);
    end
end