clc();
close all;

N = 131072;
clear opts;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 2^11;
opts{1}.banks.time.max_Q = 12;
nfo = 24;
opts{1}.banks.time.nFilters_per_octave = nfo;
opts{1}.banks.time.max_scale = inf;
opts{1}.banks.time.is_chunked = false;
opts{1}.banks.time.wavelet_handle = @morlet_1d;
opts{1}.banks.time.gamma_bounds = [1+round(2.0*nfo) round(7.0*nfo)];
opts{1}.banks.time.gammatone_order = 2;
opts{1}.invariants.time.invariance = 'summed';

opts{2}.banks.time.T = 2^15;
opts{2}.banks.time.max_Q = 1;
Q2 = 4;
opts{2}.banks.time.nFilters_per_octave = Q2;
opts{2}.banks.time.gamma_bounds = [1+10*Q2 15*Q2];
opts{2}.invariants.time.invariance = 'summed';
opts{2}.invariants.time.subscripts = [1];
opts{2}.banks.gamma.T = 2^4;
opts{2}.banks.gamma.max_Q = 1;
Q_fr = 4;
opts{2}.banks.gamma.nFilters_per_octave = Q_fr;
opts{2}.invariants.gamma.invariance = 'summed';
opts{2}.invariants.gamma.subscripts = [2];

opts{3}.invariants.time.invariance = 'summed';
opts{3}.invariants.time.subscripts = [1];
opts{3}.invariants.gamma.invariance = 'summed';
opts{3}.invariants.gamma.subscripts = [2];

archs = sc_setup(opts);
    
wav_names = { ...
    'Cb-pizz-lv-C4-mf-1c.wav', ...
    'Cb-pont-C4-mf-1c.wav', ...
    'Cb-trem-C4-mf-1c.wav', ...
    'Cb-trill-maj2-C4-mf-1c.wav', ...
    'Vc-pizz-lv-C4-mf-1c.wav', ...
    'Vc-trill-maj2-C4-mf-1c.wav'};

clf();


for wav_name_id = 1:length(wav_names)
    wav_name = wav_names{wav_name_id};
    [waveform, sr] = eca_load(wav_name, N);
    waveform = waveform / norm(waveform);

    t = 0:1/sr:N/sr;
    waveform = circshift(waveform, N/8);
    waveform = planck_taper(N, 1/8) .* waveform;

    [S, U] = sc_propagate(waveform, archs);

    lambdas = [U{1+1}{1}.variable_tree.time{1}.gamma{1}.leaf.metas.resolution] * U{1+1}{1}.variable_tree.time{1}.gamma{1}.leaf.spec.mother_xi * sr;
    lambdas = lambdas(U{1+1}{1}.ranges{2}(1):U{1+1}{1}.ranges{2}(3));
    lambda_ticks = [5000, 2000, 1000, 500, 200];
    U1_yticks = interp1(lambdas, 1:length(lambdas), lambda_ticks);


    resize_factor = 8;
    alphas = [archs{2}.banks{1}.metas.resolution]*archs{2}.banks{1}.spec.mother_xi*sr;
    alphas = alphas(S{1+2}{1,1}{1}.ranges{3}(1):S{1+2}{1,1}{1}.ranges{3}(3));
    U2_yticks = interp1(alphas, 1:length(alphas), 1:25) * resize_factor;
    n_yticks = length(U2_yticks);

    betas = [archs{2}.banks{2}.metas.resolution]*archs{2}.banks{2}.spec.mother_xi*archs{1}.banks{1}.spec.nFilters_per_octave;
    betas = betas(S{1+2}{1,1}{1}.ranges{2}{1}(1):S{1+2}{1,1}{1}.ranges{2}{1}(3));
    U2_xticks = interp1(betas, 1:length(betas), 1:10) * resize_factor;
    n_xticks = length(U2_xticks);
    %
    S2 = [S{1+2}{1,1}{1}.data{:}];
    S2_pos = rot90(cellfun(@(x) x(1), S2(:, :)));
    S2_neg = rot90(cellfun(@(x) x(2), S2(:, :)));

    S2_pos = imresize(S2_pos, resize_factor);
    S2_neg = imresize(S2_neg, resize_factor);
    S2_concat = cat(2, S2_neg(:, end:-1:1), S2_pos);

    figure(2*wav_name_id-1);
    U1_sc = display_scalogram(U{1+1}{1});
    imagesc(log1p(1e1*U1_sc(:, (1+end/8):(5*end/8))));
    xticks(round((0.5:0.5:1.0) * sr));
    xticklabels((500:500:1000));
    xlabel('$\textrm{Time (ms)}$', 'interpreter', 'latex');
    yticks(U1_yticks);
    yticklabels(lambda_ticks);
    set(gca(), 'TickLabelInterpreter', 'latex');
    ylabel('$\textrm{Frequency }\lambda\textrm{ (Hz)}$', ...
        'Interpreter', 'latex');

    colormap rev_magma;
    set(gcf(), 'Position', [200*wav_name_id, 100, ...
        120*1.618, 120]);
    export_fig([wav_name(1:(end-4)), '_scalogram.pdf']);

    figure(2*wav_name_id);
    hold on

    imagesc(S2_concat);
    for xtick_id = 1:n_xticks
        plot([U2_xticks(xtick_id), U2_xticks(xtick_id)], [0.5, 4.5], ...
            'k', 'LineWidth', 2.0);
        plot([256-U2_xticks(xtick_id), 256-U2_xticks(xtick_id)], [0.5, 4.5], ...
            'k', 'LineWidth', 2.0);
    end
    for ytick_id = 1:n_yticks
        plot([128, 128+8], ...
            [size(S2_concat, 1)-U2_yticks(ytick_id), size(S2_concat, 1)-U2_yticks(ytick_id)], ...
            'k', 'LineWidth', 2.0);
    end
    global LineWidthOrder, LineWidthOrder=[3];
    arrow3([129, 0.5], [129, size(S2_concat, 1)+8], 'k/', 1.5, 2);
    global LineWidthOrder, LineWidthOrder=[3];
    arrow3([0.5, 0.5], [256+16.5, 0.5], 'k/', 1.5, 2);
    text( ...
        136, size(S2_concat, 1) + 9, '$\alpha \textrm{ (Hz)}$', ...
        'FontSize', 24.0, 'Interpret', 'latex');
    text( ...
        256+9, 12, '$\beta \textrm{ (c/o)}$', ...
        'FontSize', 24.0, 'Interpret', 'latex');
    xlim([-18, 256+18])
    ylim([-10, size(S2_concat, 1)+31]);
    colormap rev_magma;
    hold off;
    axis off;
    set(gcf(), 'Position', [300*wav_name_id-299, 500, 300, 300]);
    set(gca(), 'SortMethod', 'ChildOrder');
    export_fig([wav_name(1:(end-4)), '_scattering.pdf']);
end