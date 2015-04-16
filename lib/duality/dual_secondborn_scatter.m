function data_out = ...
    dual_secondborn_scatter(data_in,bank,ranges,sibling,data_ft_out,ranges_out)
level_counter = length(ranges)-2;

%% Selection of signal-adapted support to the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data_in,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
dual_psis = bank.dual_psis{support_index};

%% Definition of resampling factors
gamma_subscript = bank_behavior.gamma_subscript;
gamma_range = ranges{1+1}(:,gamma_subscript);
gammas = collect_range(gamma_range);
sibling_log2_resolutions = [sibling.metas.log2_resolution];
sibling_log2_oversampling = sibling.behavior.U.log2_oversampling;
sibling_log2_samplings = ...
    min(sibling_log2_resolutions+sibling_log2_oversampling,0);
log2_resolutions = [bank.metas.log2_resolution];
log2_oversampling = bank_behavior.U.log2_oversampling;
log2_samplings = min(log2_resolutions+log2_oversampling,0);
sibling_subscript = sibling.subscripts;
sibling_matrix = zeros(length(sibling.metas),length(bank.metas));
for gamma_index = 1:length(gammas)
    gamma = gammas(gamma_index);
    sibling_range = ranges{1+0}{gamma_index}(:,sibling_subscript);
    sibling_gammas = collect_range(sibling_range);
    sibling_matrix(sibling_gammas,gamma) = 1;
end

%% Dual-scattering implementations
nThetas = size(bank.dual_psis,2);
is_deepest = size(ranges{end},2)==1;
is_oriented = nThetas>1;
subsref_structure = bank.behavior.colons;


%% D. Deepest
% e.g. dual-scattering along time
if is_deepest && ~is_oriented
    sibling_out_ranges = ranges_out{end}(:,1);
    out_sibling_gammas = collect_range(sibling_out_ranges);
    nOut_sibling_gammas = length(out_sibling_gammas);
    data_out = cell(size(data_in));
    for out_sibling_index = 1:nOut_sibling_gammas
        local_data_ft = data_ft_out{out_sibling_index};
        sibling_gamma = out_sibling_gammas(out_sibling_index);
        enabled_gammas = find(sibling_matrix(sibling_gamma,:));
        nEnabled_gammas = length(enabled_gammas);
        if nEnabled_gammas>0
            for enabled_gamma_index = 1:nEnabled_gammas
                enabled_gamma = enabled_gammas(enabled_gamma_index);
                dual_psi = dual_psis(enabled_gamma);
                log2_resampling = log2_samplings(enabled_gamma) - ...
                    sibling_log2_samplings(sibling_gamma);
                gamma_in_range = ranges{1+1}(:,1);
                in_gamma_index = search_range(gamma_in_range,enabled_gamma);
                sibling_in_range = ...
                    ranges{1+0}{in_gamma_index}(:,sibling_subscript);
                in_sibling_index = search_range(sibling_in_range,sibling_gamma);
                subsref_structure.subs{sibling_subscript} = in_sibling_index;
                local_data = subsref(data_in{in_gamma_index},subsref_structure);
                local_data_ft = multiply_fft_inplace(local_data,dual_psi, ...
                    log2_resampling,colons,subscripts,local_data_ft);
            end
        end
        data_out{out_sibling_index} = ...
            multidimensional_ifft(local_data_ft,subscripts);
    end
end
%% D.O. Oriented
% e.g. dual-scattering along 2d space
if is_deepest && is_oriented
    error('oriented dual_secondborn_scatter not ready yet');
    % This is needed e.g. for images
end
end