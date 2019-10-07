%%

wav_names = {
    'Cb-pizz-bartok-C4-ff-1c.wav', ...
    'Cb-pont-C4-mf-1c.wav', ...
    'Vn-pont-C4-mf-4c.wav', ...
    'Vc-nonvib-C4-mf-1c.wav'};

N = 32768;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = 2^7;
opts{1}.banks.time.max_Q = 24;
opts{1}.banks.time.nFilters_per_octave = 12;
opts{1}.banks.time.max_scale = inf;
opts{1}.banks.time.is_chunked = false;
opts{1}.invariants.time.invariance = 'summed';

opts{2}.banks.time.T = 2^13;
opts{2}.banks.time.max_Q = 1;
Q2 = 4;
opts{2}.banks.time.nFilters_per_octave = Q2;
opts{2}.banks.time.gamma_bounds = [1+9*Q2 1+13*Q2];
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


for wav_name_id = 1:1
    wav_name = wav_names{wav_name_id};
    [waveform, sr] = eca_load(wav_name, N);
    waveform = waveform / norm(waveform);

    t = 0:1/sr:N/sr;
    %waveform = chirp(t(1:(end-1)),50,N/sr,3200, 'logarithmic').';
    %waveform = chirp(t(1:(end-1)),100,N/sr,800, 'logarithmic').';
    %waveform = chirp(t(1:(end-1)),25,N/sr,6400, 'logarithmic').';
    %waveform = hann(N) .* waveform;
    if wav_name_id > 1
        waveform = hann(N) .* waveform;
    end

    %
    archs = sc_setup(opts);
    [S, U] = sc_propagate(waveform, archs);

    %
    S2 = [S{1+2}{1,1}{1}.data{:}];
    S2_pos = cellfun(@(x) x(1), S2(:, :));
    S2_neg = cellfun(@(x) x(2), S2(:, :));

    column = [U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{2}.leaf.metas(U{1+2}{1,1}{1}.ranges{3}(1,1):U{1+2}{1,1}{1}.ranges{3}(3,1)).resolution];
    row = [U{1+2}{1,1}{1}.variable_tree.time{1}.gamma{1}.gamma{1}.leaf.metas.resolution];

    resolution_matrix = (column' * row).';
    resolution_matrix = 1 + 0 * resolution_matrix;
    S2_pos = S2_pos .* sqrt(resolution_matrix);
    S2_neg = S2_neg .* sqrt(resolution_matrix);


    S2_pos = imresize(S2_pos, 8);
    S2_neg = imresize(S2_neg, 8);

    %
    figure(wav_name_id);
    %set(gcf(), 'WindowStyle', 'docked');
    subplot(1, 2, 1);
    imagesc(S2_pos(:,:));
    caxis([min(min(S2_neg(:)), min(S2_pos(:))), max(max(S2_neg(:)), max(S2_pos(:)))]);
    axis off;
    colormap rev_magma;
    subplot(1, 2, 2);
    imagesc(S2_neg(:, end:-1:1));
    caxis([min(min(S2_neg(:)), min(S2_pos(:))), max(max(S2_neg(:)), max(S2_pos(:)))]);
    axis off;
    colormap rev_magma
end