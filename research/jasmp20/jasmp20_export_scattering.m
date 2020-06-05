function jasmp20_export_scattering(wav_path, N, archs)
    
    [waveform, sr] = eca_load(wav_path, N);
    waveform = waveform / norm(waveform);

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

    figure(1);
    U1_sc = display_scalogram(U{1+1}{1});
    ax2 = subplot(121);
    imagesc(log1p(1e1*U1_sc(:, (1+end/8):(5*end/8))));
    xticks(round((0.5:0.5:1.0) * sr));
    xticklabels((500:500:1000));
    xlabel('$\textrm{Time (ms)}$', 'interpreter', 'latex');
    yticks(U1_yticks);
    yticklabels(lambda_ticks/1000);
    set(gca(), 'TickLabelInterpreter', 'latex');
    ylabel('$\textrm{Frequency }\lambda\textrm{ (kHz)}$', ...
        'Interpreter', 'latex');

    colormap rev_magma;
    S1_sc = log1p(1e1*sum(U1_sc(:, (1+end/8):(5*end/8)), 2));
    
    ax2 = subplot(122);
    imagesc(S1_sc);
    xticks([]);
    yticks([]);
    xlabel("$\textrm{avg.}$", "interpreter", "latex");
    set(gca(), "Position", [0.5103 0.24 0.03 0.685]);
    
    set(gcf(), 'Position', [200, 100, 200, 125]);
    set(gcf(), 'Color', 'w');
    export_fig([wav_path(1:(end-4)), '_scalogram.pdf']);

    figure(2);
    hold on

    imagesc(S2_concat);
    for xtick_id = 1:n_xticks
        plot([U2_xticks(xtick_id), U2_xticks(xtick_id)], [0.5, 4.5], ...
            'k', 'LineWidth', 1.5);
        plot([256-U2_xticks(xtick_id), 256-U2_xticks(xtick_id)], [0.5, 4.5], ...
            'k', 'LineWidth', 1);
    end
    for ytick_id = 1:n_yticks
        plot([128, 128+8], ...
            [size(S2_concat, 1)-U2_yticks(ytick_id), size(S2_concat, 1)-U2_yticks(ytick_id)], ...
            'k', 'LineWidth', 1);
    end
    global LineWidthOrder, LineWidthOrder=[2];
    arrow3([129, 0.5], [129, size(S2_concat, 1)+8], 'k/', 1.5, 2);
    global LineWidthOrder, LineWidthOrder=[2];
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
    set(gcf(), 'Position', [300, 500, 400, 300]);
    set(gca(), 'SortMethod', 'ChildOrder');
    set(gcf,'color','w');
    export_fig([wav_path(1:(end-4)), '_scattering.pdf']);
end