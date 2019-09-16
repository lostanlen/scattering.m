N = 32768;
clear opts;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 2^7;
opts{1}.banks.time.max_Q = 24;
opts{1}.banks.time.nFilters_per_octave = 24;
opts{1}.banks.time.max_scale = inf;
opts{1}.banks.time.is_chunked = false;
opts{1}.invariants.time.invariance = 'summed';

opts{2}.banks.time.T = 2^13;
opts{2}.banks.time.max_Q = 1;
Q2 = 4;
opts{2}.banks.time.nFilters_per_octave = Q2;
opts{2}.banks.time.gamma_bounds = [1+10*Q2 1+13*Q2];
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
%
note_times = [ ...
    0.380, 1.050, 2.017, 3.149, 4.143, ...
    4.909, 5.897, 7.084, 8.141, 8.991];

wav_name = 'typicalPETs.wav';
sr = 44100;

n_notes = length(note_times);

for note_id = 1:n_notes
    note_time = note_times(note_id);
    note_start = round(note_time*sr) - N/2;
    waveform = audioread(wav_name);
    waveform = waveform(note_start:(note_start+N-1));
    waveform = waveform / norm(waveform);
    %t = 0:1/sr:N/sr;
    %waveform = chirp(t(1:(end-1)),150,N/sr,16000, 'logarithmic').';
    %waveform = waveform .* hann(N);
    %waveform = waveform(end:-1:1);

    archs = sc_setup(opts);
    [S, U] = sc_propagate(waveform, archs);

    % Adaptive time-frequency scattering
    S1 = [S{1+1}{1}.data{:}];
    S1 = S1 .* [S{1+1}{1}.variable_tree.time{1}.gamma{1}.leaf.metas.resolution];
    [~, gamma1_argmax_id] = max(S1);
    gamma1_range = S{1+1}{1}.ranges{1+1}(1):S{1+1}{1}.ranges{1+1}(2):S{1+1}{1}.ranges{1+1}(3);
    gamma1_argmax = gamma1_range(gamma1_argmax_id);

    n_gamma2s = length(U{1+2}{1,1}{1}.data);
    n_gamma_gammas = length(U{1+2}{1,1}{1}.data{1});

    U2_pos = zeros(n_gamma_gammas, n_gamma2s);
    U2_neg = U2_pos;
    U2_zero = zeros(1, n_gamma2s);

    for gamma2_id = 1:n_gamma2s
        for gamma_gamma_id = 1:n_gamma_gammas
            local_U2_range = ...
                U{1+2}{1,1}{1}.ranges{1+0}{gamma2_id}{gamma_gamma_id};
            local_gamma1_id = ...
                round((gamma1_argmax-local_U2_range(1, 2)) / ...
                local_U2_range(2, 2));
            local_multiplier = 1/(local_U2_range(2, 1) * local_U2_range(2, 2));
            U2_pos(gamma_gamma_id, gamma2_id) = local_multiplier * ...
                U{1+2}{1,1}{1}.data{gamma2_id}{gamma_gamma_id}(end/2,local_gamma1_id, 2);
            U2_neg(gamma_gamma_id, gamma2_id) = local_multiplier * ...
                U{1+2}{1,1}{1}.data{gamma2_id}{gamma_gamma_id}(end/2,local_gamma1_id, 1);
        end
        local_U2_range = U{1+2}{1,2}{1}.ranges{1+0}{gamma2_id};
        local_multiplier = 1/(local_U2_range(2, 1) * local_U2_range(2, 2));
        local_gamma1_id = ...
            round((gamma1_argmax-local_U2_range(1, 2)) / ...
            local_U2_range(2, 2));
        U2_zero(gamma2_id) = local_multiplier * ...
            U{1+2}{1,2}{1}.data{gamma2_id}(end/2,local_gamma1_id);
    end

    U2_adaptive = cat(1, ...
        U2_pos(:, end:-1:1), U2_zero(:, end:-1:1), U2_neg(end:-1:1, end:-1:1));
    imresize_factor = 8;
    U2_adaptive = imresize(U2_adaptive, imresize_factor);
    imagesc(U2_adaptive);
    colormap rev_magma;

    %
    gamma2_resolutions = [U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{2}.leaf.metas.resolution];
    gamma_gamma_resolutions = [U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.metas.resolution];

    gamma2_xi = U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{2}.leaf.spec.mother_xi;
    gamma_gamma_xi = U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.spec.mother_xi;

    gamma2_frequencies = sr * gamma2_xi * gamma2_resolutions;
    gamma2_frequencies = gamma2_frequencies(U{1+2}{1}{1}.ranges{1+2}(3):-1:U{1+2}{1}{1}.ranges{1+2}(1));
    gamma2_frequencies = logspace(log10(gamma2_frequencies(1)), log10(gamma2_frequencies(end)), ...
        size(U2_adaptive, 2));

    gamma_gamma_sr = opts{1}.banks.time.nFilters_per_octave;
    gamma_gamma_frequencies = gamma_gamma_sr * gamma_gamma_xi * gamma_gamma_resolutions;
    gamma_gamma_frequencies = logspace(log10(gamma_gamma_frequencies(1)), log10(gamma_gamma_frequencies(end)), ...
        (size(U2_adaptive, 1)-imresize_factor)/2);
    gamma_gamma_linspace = linspace(-gamma_gamma_frequencies(end), gamma_gamma_frequencies(end), 2+imresize_factor);
    gamma_gamma_frequencies = cat(2, ...
        -gamma_gamma_frequencies, ...
        gamma_gamma_linspace(2:(end-1)), ...
        gamma_gamma_frequencies(end:-1:1));

    xlabel('Temporal modulation rate (Hz)');
    ylabel('Frequential modulation scale (c/o)');

    xtick_labels = [3, 4, 6, 8, 12, 16];
    xtick_ids = zeros(1, length(xtick_labels));
    for xtick_label_id = 1:length(xtick_labels)
        [~, xtick_id] = min(abs(gamma2_frequencies-xtick_labels(xtick_label_id)));
        xtick_ids(xtick_label_id) = xtick_id;
    end
    xticks(xtick_ids);
    xticklabels(xtick_labels);

    ytick_labels = [-10, -5, -2, -1, 0, 1, 2, 5, 10];
    ytick_ids = zeros(1, length(ytick_labels));
    for ytick_label_id = 1:length(ytick_labels)
        [~, ytick_id] = min(abs(gamma_gamma_frequencies-ytick_labels(ytick_label_id)));
        ytick_ids(ytick_label_id) = ytick_id;
    end
    yticks(ytick_ids);
    yticklabels(ytick_labels);

    set(gcf, 'Position', [100, 100, 220, 220]);
    eps_name = ['wang2019icassp_fig_joint_', int2str(note_id-1), '.pdf'];
    export_fig(eps_name);
end