file_dir = '/scratch/vl1019/stocha';
file_str = 'Stocha_Acid_Zlook_m48_R.wav';
[y, sr] = audioread(fullfile(file_dir, file_str));
max_y = max(abs(y));

%%
Q1 = 12; % number of filters per octave at first order
T = 2^14; % amount of invariance with respect to time translation

opts{1}.time.nFilters_per_octave = Q1;
opts{1}.time.T = T;
opts{1}.time.max_scale = 8192;
opts{1}.time.size = max(4*T, 2^(10 + nextpow2(Q1)));
opts{1}.time.is_chunked = true;
opts{1}.time.is_unchunked = true;
opts{1}.time.gamma_bounds = [1 Q1*9];
opts{1}.time.duality = 'hermitian';
opts{1}.time.wavelet_handle = @morlet_1d;

opts{2}.time.nFilters_per_octave = 1;
opts{2}.time.wavelet_handle = @morlet_1d;
opts{2}.time.duality = 'hermitian';
opts{2}.time.wavelet_handle = @morlet_1d;
opts{2}.gamma.T = 32; % 32 semitones of gamma filtering
opts{2}.gamma.invariance = 'blurred';
opts{2}.gamma.duality = 'hermitian';
opts{2}.gamma.nFilters_per_octave = 1;
opts{2}.gamma.subscripts = 3;

archs = sc_setup(opts);

% Setup reconstruction options
opts = struct();
opts.nChunks_per_batch = 2; % must be > 1
opts.export_folder = file_dir;
opts.export_mode = 'all'; % should be 'all' or 'last'
opts.nIterations = 50;
opts.generate_text = false; % "true" will work only with time-frequency scattering
opts.bit_depth = 24;
opts.is_initialization_localized = true;
opts.sample_rate = sr;


% Do not change the parameters below
opts.is_sonified = false;
opts.is_spectrogram_displayed = false;
% (close Figure 1 to abort early)
opts.verbose = true;
opts.initial_learning_rate = 0.1;


% Default options
opts.generate_text = default(opts, 'generate_text', false);
if opts.generate_text
    opts.nLines = default(opts, 'nLines', Inf);
end
opts.display_text = default(opts, 'display_text', false);
opts.adapt_learning_rate = default(opts, 'adapt_learning_rate', false);
opts.export_folder = default(opts, 'export_folder', '');
opts = fill_reconstruction_opt(opts);

%% Initialization
N = archs{1}.banks{1}.spec.size;
target_chunks = eca_split(y, N);
nChunks = size(target_chunks, 2);

% Group target chunks into batches
nChunks_per_batch = min(nChunks, opts.nChunks_per_batch);
% We want to avoid having only one chunk in the last batch
if mod(nChunks, nChunks_per_batch) == 1
    nBatches = (nChunks - 1) / nChunks_per_batch;
else
    nBatches = ceil(nChunks / nChunks_per_batch);
end
target_batches = cell(1, nBatches);
batch_sizes = zeros(1, nBatches);
for batch_index = 0:(nBatches-1)
    batch_start = 1 + batch_index * nChunks_per_batch;
    batch_stop = min((batch_index+1) * nChunks_per_batch, nChunks);
    if batch_stop == (nChunks - 1)
        batch_stop = nChunks;
    end
    target_batches{1+batch_index} = target_chunks(:, batch_start:batch_stop);
    batch_sizes(1+batch_index) = batch_stop - batch_start + 1;
end

% Forward propagation of target
target_S_batches = cell(1, nBatches);
for batch_index = 0:(nBatches-1)
    target_S = eca_propagate(target_batches{1+batch_index}, archs);

    % Reverse
    target_S_rev = target_S;
    nTemporal_scales = length(target_S{1+2}{1,1}.data);
    for j2_tm = 1:nTemporal_scales
        nFrequency_scales = length(target_S{1+2}{1,1}.data{j2_tm});
        for j_fr = 1:nFrequency_scales
            backward_slice = target_S{1+2}{1,1}.data{j2_tm}{j_fr}(:, :, :, 2:-1:1);
            target_S_rev{1+2}{1,1}.data{j2_tm}{j_fr} = backward_slice;
        end
    end

    target_S_batches{1+batch_index} = target_S_rev;
end

% Initialization
loss_batches = zeros(nBatches, opts.nIterations);
signal_update_batches = ...
    arrayfun(@(x) zeros(N, x), batch_sizes, 'UniformOutput', false);
learning_rate_batches = opts.initial_learning_rate * ones(1, nBatches);
max_nDigits = 1 + floor(log10(opts.nIterations));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];
texts = cell(1, 1 + opts.nIterations);
sounds = cell(1, 1 + opts.nIterations);
hann_window = hann(N);
chunks = zeros(N, nChunks);
if opts.is_initialization_localized
    for chunk_index = 0:(nChunks-1)
        chunk = generate_colored_noise(target_chunks(:, 1+chunk_index));
        chunk = chunk .* hann_window;
        chunks(:, 1+chunk_index) = chunk;
    end
    sounds{1+0} = eca_overlap_add(chunks);
else
    y_init = randn(size(y));
    sounds{1+0} = y_init * norm(y)/norm(y_init);
end

%% Iterated reconstruction
generate_text = opts.generate_text;
iteration = 1;
U_batches = cell(1, nBatches);
figure_handle = gcf();
tic();
while (iteration <= opts.nIterations) && ishandle(figure_handle)
    if opts.verbose
        disp(iteration);toc(); tic();
    end

    %% Split into chunks
    chunks = eca_split(sounds{iteration}, N);

    %% Batch computation
    batches = cell(1, nBatches);
    for batch_index = 0:(nBatches-1)
        % Select chunks
        batch_start = 1 + batch_index * nChunks_per_batch;
        batch_stop = min((batch_index+1) * nChunks_per_batch, nChunks);
        if batch_stop == (nChunks - 1)
            batch_stop = nChunks;
        end
        batches{1+batch_index} = chunks(:, batch_start:batch_stop);
    end
    if opts.generate_text
        S_batches = cell(1, nBatches);
    end
    for batch_index = 0:(nBatches-1)

        % Load batch
        batch = batches{1+batch_index};
        % Forward propagation
        [S, U, Y] = eca_propagate(batch, archs);
        if generate_text
            S_batches{1+batch_index} = S;
        end
        U_batches{1+batch_index} = U(1:2);
        target_S = target_S_batches{1+batch_index};
        % Cancel first-order!
        %target_S{1+1}.data = 0 * target_S{1+1}.data;
        %S{1+1}.data = 0 * S{1+1}.data;
        % Substraction
        delta_S = sc_substract(target_S, S);
        % Backpropagation
        delta_batch = sc_backpropagate(delta_S, U, Y, archs);
        % Get learning rate and momentum
        learning_rate = learning_rate_batches(1+batch_index);
        signal_update = signal_update_batches{1+batch_index};
        % Update signal
        [batch, signal_update] = update_reconstruction(batch, delta_batch, ...
            signal_update, learning_rate, opts);
        batches{1+batch_index} = batch;
        % Update learning rate and momentum
        learning_rate_batches(1+batch_index) = learning_rate;
        signal_update_batches{1+batch_index} = signal_update;
    end
    chunks = [batches{:}];
    sounds{1+iteration} = eca_overlap_add(chunks);

    %% Pretty-printing of scattering distances and loss function
     if opts.verbose
         if opts.adapt_learning_rate
            average_learning_rate = mean(learning_rate_batches);
            average_learning_rate_str = ...
                num2str(average_learning_rate, '%0.4f');
            disp(['Average learning rate = ', average_learning_rate_str]);
         end
         toc();
         tic();
     end

    %% Display
    if opts.is_spectrogram_displayed
        plot(sounds{1+iteration});
        drawnow();
    end

    %% Sonification
    if opts.is_sonified
        soundsc(sounds{1+iteration}, opts.sample_rate);
    end

    %% Text generation
    if opts.generate_text
        text = eca_text(S_batches, opts.nLines, opts.sample_rate);
        texts{1+iteration} = text;
    end

    %% Export
    if opts.export_mode == "all"
        export_file_str = [file_str(1:(end-4)), '_it', ...
            sprintf('%0.2d', iteration), '.wav'];
        export_path_str = fullfile(opts.export_folder, export_file_str);
        audiowrite(export_path_str, ...
            sounds{1+iteration}/max(abs(sounds{1+iteration})) * max_y, ...
            opts.sample_rate, 'BitsPerSample', opts.bit_depth);
    end

    %% Clock tick
    iteration = iteration + 1;
end
toc();

sounds{1+0} = [];
sounds(cellfun(@isempty, sounds)) = [];
texts(cellfun(@isempty, texts)) = [];

%% Export
if opts.export_mode == "last"
    export_file_str = [file_str(1:(end-4)), '_it', ...
        sprintf('%0.2d', iteration), '.wav'];
    export_path_str = fullfile(opts.export_folder, export_file_str);
    audiowrite(export_path_str, ...
        sounds{1+iteration}/max(abs(sounds{1+iteration})) * max_y, ...
        opts.sample_rate, 'BitsPerSample', opts.bit_depth);
end
