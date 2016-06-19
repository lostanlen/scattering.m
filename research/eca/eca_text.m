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
gamma1_metas = gamma1_metas(S1_range(1):S1_range(2):S1_range(3));
S1_gamma1_resolutions = [gamma1_metas.resolution];
S1_gamma1_frequencies = S1_gamma1_resolutions * gamma1_mother_frequency;
[S1_sorted_norms, S1_sorting_indices] = sort(S1_norms, 'descend');
S1_sorted_ppms = round((S1_sorted_norms / sum(S1_sorted_norms)) * 10^6);
S1_gamma1_frequencies = round(S1_gamma1_frequencies(S1_sorting_indices));
S1_text = arrayfun(@(ppm, f1) ...
    sprintf([repmat(' ', 1, 4 - floor(log10(ppm))), ...
    num2str(ppm), ' ppm  ', ...
    repmat(' ', 1, 4 - floor(log10(f1))), ...
    num2str(f1), ' Hz\n']), ...
    S1_sorted_ppms, S1_gamma1_frequencies, ...
        'UniformOutput', false);
S1_text = [S1_text{:}];

%% psi-psi
S2psi_refs = generate_refs(S{1+2}{1}.data, [1, 2], S{1+2}{1}.ranges{1});
nS2psi_refs = length(S2psi_refs);
first_tensor = subsref(S{1+2}{1}.data, S2psi_refs(:,3));
S2_psi_data = zeros(size(first_tensor, 1), size(first_tensor, 2), nS2psi_refs);

for ref_index = 1:nS2psi_refs
    S2psi_data(:,:,ref_index) = ...
        subsref(S{1+2}{1}.data, S2psi_refs(:, ref_index));
end
S2psi_norms = squeeze(sum(sum(S2psi_data.*S2psi_data, 1), 2)).';
%%
gamma2_motherfrequency = sample_rate * ...
    S{1+2}{1}.variable_tree.time{1}.gamma{2}.leaf.spec.mother_xi;
S2psi_gamma2_subs = [S2psi_refs(1,:).subs];
S2psi_gamma2_indices = [S2psi_gamma2_subs{:}];
S2psi_gamma2s = S2psi_gamma2_indices + (S{1+2}{1}.ranges{3}(1) - 1);
S2psi_gamma2_metas = ...
    S{1+2}{1}.variable_tree.time{1}.gamma{2}.leaf.metas(S2psi_gamma2s);
S2psi_gamma2_resolutions = [S2psi_gamma2_metas.resolution];
S2psi_gamma2_frequencies = S2psi_gamma2_resolutions * gamma2_motherfrequency;
%%
gammagamma_motherfreqency = ...
    S{1+2}{1}.variable_tree.time{1}.gamma{1}.leaf.spec.nFilters_per_octave * ...
    S{1+2}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.spec.mother_xi;
gammagamma_subs = [S2psi_refs(2,:).subs];
gammagamma_indices = [gammagamma_subs{:}];
gammagammas = zeros(1, nS2psi_refs);
for ref_index = 1:nS2psi_refs
    gamma2_index = S2psi_gamma2_indices(ref_index);
    gammagammas(ref_index) = gammagamma_indices(ref_index) + ...
        (S{1+2}{1}.ranges{2}{gamma2_index}(1) - 1);
end
S2psi_gammagamma_metas = ...
    S{1+2}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.metas(gammagammas);
S2psi_gammagamma_resolutions = [S2psi_gammagamma_metas.resolution];
S2psi_gammagamma_frequencies = ...
    S2psi_gammagamma_resolutions * gammagamma_motherfreqency;
%%
S2psi_gamma1_subs = [S2psi_refs(2,:).subs];
S2psi_gamma1_subs = S2psi_gamma1_subs(3, :);
S2psi_gamma1_indices = [S2psi_gamma1_subs{:}];
S2psi_gamma1s = zeros(1, nS2psi_refs);
for ref_index = 1:nS2psi_refs
    gamma2_index = S2psi_gamma2_indices(ref_index);
    gammagamma_index = gammagamma_indices(ref_index);
    S2psi_gamma1s(ref_index) = ...
        (S{1+2}{1}.ranges{1}{gamma2_index}{gammagamma_index}(1) - 1);
    %S2psi_gamma1s(ref_index) = S2psi_gamma1_indices(ref_index) + ...
    %    (S{1+2}{1}.ranges{1}{gamma2_index}{gammagamma_index}(1) - 1);
end
S2psi_gamma1_resolutions = [gamma1_metas(S2psi_gamma1s).resolution];
S2psi_gamma1_frequencies = S2psi_gamma1_resolutions * gamma1_mother_frequency;
%%
S2_psi_thetagamma_subs = [S2psi_refs(3,:).subs];
S2psi_thetagamma_indices = S2_psi_thetagamma_subs(4, :);
S2psi_thetagammas = 2 * [S2psi_thetagamma_indices{:}] - 3;

%%

