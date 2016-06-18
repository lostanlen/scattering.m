function text = eca_text(y, archs, sample_rate)
%% Divide into chunks
N = archs{1}.banks{1}.spec.size;
chunks = eca_split(y, N);

%%
S = eca_target(chunks, archs);

%%
gamma1_metas = S{1+1}.variable_tree.time{1}.gamma{1}.leaf.metas;
gamma1_mother_frequency = ...
    sample_rate * S{1+1}.variable_tree.time{1}.gamma{1}.leaf.spec.mother_xi;

S1_data = S{1+1}.data;
S1_norms = squeeze(sum(sum(S1_data.*S1_data, 1), 2)).';
S1_range = S{1+1}.ranges{1}(:,3);
S1_metas = gamma1_metas(S1_range(1):S1_range(2):S1_range(3));
gamma1_resolutions = [S1_metas.resolution];
gamma1_frequencies = gamma1_resolutions * gamma1_mother_frequency;
[S1_sorted_norms, S1_sorting_indices] = sort(S1_norms, 'descend');
S1_sorted_ppms = round((S1_sorted_norms / sum(S1_sorted_norms)) * 10^6);
S1_gamma1_frequencies = round(gamma1_frequencies(S1_sorting_indices));
S1_text = arrayfun(@(ppm, f1) ...
    sprintf([repmat(' ', 1, 4 - floor(log10(ppm))), ...
    num2str(ppm), ' ppm  ', ...
    repmat(' ', 1, 4 - floor(log10(f1))), ...
    num2str(f1), ' Hz\n']), ...
    S1_sorted_ppms, S1_gamma1_frequencies, ...
        'UniformOutput', false);
S1_text = [S1_text{:}];
end