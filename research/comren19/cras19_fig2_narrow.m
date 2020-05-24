audio_name = 'TpC-trill-min2-C4-mf.wav';
N = 2^18;
Q1 = 36;
T = N;

[y, sample_rate] = eca_load(audio_name, N);

opts = cell(2, 1);
opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = T;
opts{1}.time.max_scale = 4096;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.gamma_bounds = [1+round(Q1*1.5), round(Q1*7.5)];

opts{2}.time.nFilters_per_octave = 4;
opts{2}.time.sibling_mask_factor = 1;

opts{2}.gamma.nFilters_per_octave = 1;
opts{2}.gamma.is_U_blurred = true;
opts{2}.gamma.is_U_scattered = true;
opts{2}.gamma.U_log2_oversampling = Inf;


archs = sc_setup(opts);

%%
[S, U] = sc_propagate(y, archs);
scalogram = display_scalogram(U{2});

%%
dur = length(y)/sample_rate;
times = linspace(0, dur, size(scalogram, 2));
scales = opts{1}.time.gamma_bounds(1):opts{1}.time.gamma_bounds(2);
lambdas = [archs{1}.banks{1}.metas(scales).resolution];
mother_xi = sample_rate * archs{1}.banks{1}.spec.mother_xi;
xis = mother_xi * lambdas;
tick_xis = [200, 500, 1000, 2000, 5000];
[~, tick_indices] = min(abs(tick_xis.'./xis - 1), [], 2);

figure(1);
set(gcf,'DefaultLegendInterpreter','latex') 
set(gcf,'DefaultTextInterpreter','latex')
set(gcf,'defaultAxesTickLabelInterpreter','latex')
set(gcf,'Position',[100 100 250 165])
%set(gcf(), 'WindowStyle', 'docked')
imagesc(times, scales, log1p(scalogram(:, 1:(end))*0.01));
yticks(sort(scales(tick_indices)));
yticklabels(tick_xis(end:-1:1)/1000);
colormap rev_hot;

xlabel('Temps (s)');
ylabel("Fr\'equence porteuse (kHz)");
title({'', 'Scalogramme en ondelettes'});


export_fig cras19_fig2a_french.png -m4 -transparent

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

set(0,'DefaultLegendInterpreter','latex') 
set(0,'DefaultTextInterpreter','latex')
set(0,'defaultAxesTickLabelInterpreter','latex')

figure(2);
set(gcf,'Position',[100 100 165 165])
hold on;
plot(alphas, S2_slice.', '-', ...
    'Color', 'k', 'LineWidth', 2.0);
plot([6, 6], [0, 29], ...
    'LineStyle', '--', 'Color', '#CB0003', 'LineWidth', 1.5);
plot([0, 30], [0, 0], 'k');
plot([0, 0], [0, 29], 'k');
hold off;

text(8, 23, 'Taux de trille : 6 Hz', 'Color', '#CB0003');

xlim([0, 30]);
ylim([0, 27]);
xlabel("Fr\'equence modul\'ee (Hz)");
ylabel("\'Energie diffus\'ee");
title(["Diffusion temps--fr\'equence", "Porteuse : 530 Hz", "\'Echelle : 14 c/o"]);
yticks([]);
box off;


export_fig cras19_fig2b_french.png -m4 -transparent

%%

j2 = 33;
j1 = 119;

beta_psi_slice = zeros(6, 2);

for j_fr = 1:6
    beta_psi_slice(j_fr, 1) = S{1+2}{1, 1}.data{j2}{j_fr}(1, j1, 1);
    beta_psi_slice(j_fr, 2) = S{1+2}{1, 1}.data{j2}{j_fr}(1, j1, 2);
end

plot(cat(1, beta_psi_slice(end:-1:1, 1), beta_psi_slice(:, 2)));