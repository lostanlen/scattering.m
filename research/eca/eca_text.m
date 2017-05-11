function [text, S_sorted_paths] = eca_text(S_batches, nLines, sample_rate)
nBatches = length(S_batches);
S_batch_norms = cell(1, nBatches);

for batch_index = 0:(nBatches-1)
    S = S_batches{1+batch_index};
    gamma1_start = S{1+1}.ranges{1}(1,3);
    S1_refs = generate_refs(S{1+1}.data, [1, 2], S{1+1}.ranges{1});
    nS1_refs = length(S1_refs);
    S1_paths(1:nS1_refs) = struct( ...
        'gamma', [], 'gamma2', [], ...
        'gammagamma', [], 'thetagamma', []);
    S1_norms = zeros(1, nS1_refs);
    for ref_index = 1:nS1_refs
        gamma1_index = S1_refs(ref_index).subs{3};
        gamma1 = (gamma1_index - 1) + gamma1_start;
        S1_paths(ref_index).gamma = gamma1;
        S1_tensor = subsref(S{1+1}.data, S1_refs(:, ref_index));
        S1_norms(ref_index) = sum(sum(S1_tensor.*S1_tensor, 1), 2).';
    end

    S2psi_refs = generate_refs(S{1+2}{1}.data, [1, 2], ...
        S{1+2}{1}.ranges{1});
    nS2psi_refs = length(S2psi_refs);
    S2psi_paths(1:nS2psi_refs) = struct( ...
        'gamma', [], 'gamma2', [], ...
        'gammagamma', [], 'thetagamma', []);
    S2psi_norms = zeros(1, nS2psi_refs);
    gamma2_start = S{1+2}{1}.ranges{3}(1);
    for ref_index = 1:nS2psi_refs
        S2psi_path = struct( ...
            'gamma', [], 'gamma2', [], ...
            'gammagamma', [], 'thetagamma', []);
        S2psi_tensor = subsref(S{1+2}{1}.data, S2psi_refs(:, ref_index));
        S2psi_norms(ref_index) = ...
            sum(sum(S2psi_tensor.*S2psi_tensor, 1), 2).';
        gamma2_index = S2psi_refs(1,ref_index).subs{1};
        S2psi_path.gamma2 = gamma2_index + (gamma2_start - 1);
        gammagamma_index = S2psi_refs(2,ref_index).subs{1};
        gammagamma_start = S{1+2}{1}.ranges{2}{gamma2_index}(1);
        S2psi_path.gammagamma = gammagamma_index + (gammagamma_start - 1);
        gamma1_index = S2psi_refs(3,ref_index).subs{3};
        gamma1_range = ...
            S{1+2}{1}.ranges{1}{gamma2_index}{gammagamma_index}(:,3);
        gamma1_start = gamma1_range(1);
        gamma1_hop = gamma1_range(2);
        S2psi_path.gamma = (gamma1_index - 1) * gamma1_hop + gamma1_start;
        thetagamma_index = S2psi_refs(3,ref_index).subs{4};
        S2psi_path.thetagamma = thetagamma_index * 2 - 3;
        S2psi_paths(ref_index) = S2psi_path;
    end

    S2phi_refs = generate_refs(S{1+2}{1,2}.data, [1, 2], ...
        S{1+2}{1,2}.ranges{1});
    nS2phi_refs = length(S2phi_refs);
    S2phi_paths(1:nS2phi_refs) = struct( ...
        'gamma', [], 'gamma2', [], ...
        'gammagamma', [], 'thetagamma', []);
    gamma2_start = S{1+2}{1,2}.ranges{2}(1);
    S2phi_norms = zeros(1, nS2phi_refs);
    for ref_index = 1:nS2phi_refs
        S2phi_path = struct( ...
            'gamma', [], 'gamma2', [], ...
            'gammagamma', [], 'thetagamma', []);
        S2phi_tensor = subsref(S{1+2}{1,2}.data, S2phi_refs(:, ref_index));
        S2phi_norms(ref_index) = ...
            sum(sum(S2phi_tensor.*S2phi_tensor, 1), 2).';
        gamma2_index = S2phi_refs(1,ref_index).subs{1};
        S2phi_path.gamma2 = gamma2_index + (gamma2_start - 1);
        gamma1_index = S2phi_refs(2,ref_index).subs{3};
        gamma1_range = ...
            S{1+2}{1,2}.ranges{1}{gamma2_index}(:,3);
        gamma1_start = gamma1_range(1);
        gamma1_hop = gamma1_range(2);
        S2phi_path.gamma = (gamma1_index - 1) * gamma1_hop + gamma1_start;
        S2phi_paths(ref_index) = S2phi_path;
    end
    S_norms = [S1_norms, S2phi_norms, S2psi_norms];
    S_batch_norms{1+batch_index} = S_norms;
    S_paths = [S1_paths, S2phi_paths, S2psi_paths];
end
S_batch_norms = cat(1, S_batch_norms{:});
S_norms = sqrt(sum(S_batch_norms .* S_batch_norms, 1));

%%
[S_sorted_norms, S_sorting_indices] = sort(S_norms, 'descend');
S_sorted_ppms = round((S_sorted_norms / sum(S_sorted_norms)) * 10^6);
if isnan(nLines)
    nLines = find(S_sorted_ppms > 0, 1, 'last');
elseif isinf(nLines)
    nLines = length(S_sorted_ppms);
end
S_sorting_indices = S_sorting_indices(1:nLines);

%
gamma1_motherfrequency = sample_rate * ...
    S{1+1}.variable_tree.time{1}.gamma{1}.leaf.spec.mother_xi;
gamma1_frequencies = gamma1_motherfrequency * ...
    [S{1+1}.variable_tree.time{1}.gamma{1}.leaf.metas.resolution];
gamma2_motherfrequency = sample_rate * ...
    S{1+2}{1}.variable_tree.time{1}.gamma{2}.leaf.spec.mother_xi;
gamma2_frequencies = gamma2_motherfrequency * ...
    [S{1+2}{1}.variable_tree.time{1}.gamma{2}.leaf.metas.resolution];
gammagamma_motherfrequency = ...
    S{1+2}{1}.variable_tree.time{1}.gamma{1}.leaf.spec.nFilters_per_octave * ...
    S{1+2}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.spec.mother_xi;
gammagamma_frequencies = gammagamma_motherfrequency * ...
    [S{1+2}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.metas.resolution];
    

S_sorted_paths = S_paths(S_sorting_indices);
S_lines = cell(1, nLines);
for line_index = 1:nLines
    ppm = S_sorted_ppms(line_index);
    S_path = S_sorted_paths(line_index);
    gamma1 = S_path.gamma;
    gamma2 = S_path.gamma2;
    gammagamma = S_path.gammagamma;
    thetagamma = S_path.thetagamma;
    ppm_string = ['\t', num2str(ppm), ' ppm'];
    f1 = gamma1_frequencies(gamma1);
    f1_string = ['\t', num2str(round(f1)), ' Hz'];
    f2 = gamma2_frequencies(gamma2);
    if f2
        f2_string = ['\t', num2str(round(f2)), ' Hz'];
    else
        f2_string = '\t';
    end
    fgamma = gammagamma_frequencies(gammagamma);
    if fgamma
        if thetagamma == 1
            sign_str = '+';
        elseif thetagamma == -1
            sign_str = '-';
        end
        fgamma_string = ['\t', sign_str, num2str(fgamma), ' c/o'];
    else
        fgamma_string = '\t';
    end
    S_line = [ppm_string, f1_string, f2_string, fgamma_string, '\n'];
    S_lines{line_index} = S_line;
end
text = sprintf([S_lines{:}]);
end
