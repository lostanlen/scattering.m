function data_ft = dual_secondborn_blur(data, invariant, ranges, sibling)
%% Deep map across levels
level_counter = length(ranges) - sibling.level - 2;
input_sizes = drop_trailing(size(data), 1);
if level_counter>0
    error('level_counter>0 in dual_secondborn_blur not ready yet');
elseif level_counter==0
    error('level_counter==0 in dual_secondborn_blur not ready yet');
else
    is_deepest = true;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = invariant.behavior;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data, ranges, subscripts);
support_index = 1 + log2(invariant.spec.size/signal_support);
dual_phi = invariant.dual_phi{support_index};

%% Definition of resampling factors
critical_log2_sampling = 1 - invariant.spec.J;
S_log2_oversampling = bank_behavior.S.log2_oversampling;
U_log2_oversampling = sibling.behavior.U.log2_oversampling;
sibling_subscript = sibling.subscripts;
gammas = collect_range(ranges{end}(:,sibling_subscript));
log2_samplings = ...
    min(U_log2_oversampling + [sibling.metas(gammas).log2_resolution].', 0);
log2_resamplings = ...
    log2_samplings - (critical_log2_sampling+S_log2_oversampling);
nGammas = length(gammas);

%%
nSubscripts = length(input_sizes);
overhead_subsref_structure = substruct('()', replicate_colon(nSubscripts-1));
colons = bank_behavior.colons;

%% Dual blurring implemnentations
% D. Deepest
% e.g. time scattering of 1d signals
if is_deepest
    data_ft = cell(nGammas,1);
    for gamma_index = 1:nGammas
        local_subsref_structure = overhead_subsref_structure;
        local_subsref_structure.subs{sibling_subscript} = gamma_index;
        log2_resampling = log2_resamplings(gamma_index);
        x = subsref(data,local_subsref_structure);
        data_ft{gamma_index} = ...
            multiply_fft(x, dual_phi, log2_resampling, colons, subscripts);
    end
end
end