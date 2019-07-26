audio_name = 'TpC-trill-min2-C4-mf.wav';
N = 2^18;
Q1 = 36;
T = N;

[y, sample_rate] = eca_load(audio_name, N);

opts = cell(2, 1);
opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = T;
opts{1}.time.max_scale = Inf;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1+round(Q1*1.5), round(Q1*7.5)];

opts{2}.time.nFilters_per_octave = 8;
opts{2}.time.max_Q = 4;
opts{2}.time.sibling_mask_factor = 1;

opts{2}.gamma.nFilters_per_octave = 1;
opts{2}.gamma.is_U_blurred = true;
opts{2}.gamma.is_U_scattered = false;
opts{2}.gamma.log2_U_oversampling = Inf;


archs = sc_setup(opts);

%%
[S, U] = sc_propagate(y, archs);
scalogram = display_scalogram(U{2});

%%
imagesc(log1p(scalogram*0.01));

%%
J2s = 5:45;
J1s = [119];
S2_slice = zeros(length(J1s), length(J2s));
for j1_id = 1:length(J1s)
    j1 = J1s(j1_id);
    for j2_id = 1:length(J2s)
        j2 = J2s(j2_id);
        S2_slice(j1_id, j2_id) = ...
            S{3}{1,1}.data{j2}{1}(1, j1, 2);
    end
end

xi = sample_rate * archs{2}.banks{1}.spec.mother_xi;

all_resolutions = [archs{2}.banks{1}.metas.resolution];
J2_range = J2s + S{3}{1,1}.ranges{3}(1) - 1;
alphas = xi * all_resolutions(J2_range);
plot(alphas, S2_slice.', '-', 'LineWidth', 2.0);
xlim([0, 30]);
ylim([0, 30]);

%%


%%
clc();

J2s = 12:80;
J1s = [2];
S2_slice = zeros(length(J1s), length(J2s));
for j1_id = 1:length(J1s)
    j1 = J1s(j1_id);
    for j2_id = 1:length(J2s)
        j2 = J2s(j2_id);
        S2_slice(j1_id, j2_id) = ...
            S{3}{1,2}.data{j2}(2, j1);
    end
end

xi = sample_rate * archs{2}.banks{1}.spec.mother_xi;

all_resolutions = [archs{2}.banks{1}.metas.resolution];
J2_range = J2s + S{3}{1,2}.ranges{2}(1) - 1;
alphas = xi * all_resolutions(J2_range);
plot(alphas, S2_slice.', '-', 'LineWidth', 2.0);
%xlim([0, 25]);