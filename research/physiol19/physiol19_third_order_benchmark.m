%% PART 1. WITHOUT ACCELERATION.
clc(); clear all;

signal_lengths = [6e6];
%signal_lengths = ...
%    [1e4, 2e4, 5e4, 1e5, 2e5, 5e5, 1e6, 2e6, 5e6, 1e7];
n_signals = length(signal_lengths);
delta_ts = zeros(n_signals, 2);

sample_rate = 200; % in Hertz
min_frequency_in_Hertz = 0.1; % in seconds
hop_size_in_seconds = 0.5; % in seconds
Qs = [1, 1, 1]; % quality factor at the first, second, and third layers

T_psi = pow2(nextpow2(sample_rate / min_frequency_in_Hertz));
T_phi = pow2(nextpow2(sample_rate * hop_size_in_seconds)) ;


disp('************************************************************')
disp('PART 1: PLAIN THIRD-ORDER SCATTERING')

opts = cell(1, 4);
opts{1}.banks.time.T = T_psi;
opts{1}.banks.time.max_Q = Qs(1);
opts{1}.banks.time.max_scale = Inf;
opts{1}.banks.time.size = 4*T_psi;
opts{1}.banks.time.is_chunked = true;
opts{1}.banks.time.is_unchunked = true;
opts{1}.banks.time.is_windowed = true;
opts{1}.banks.time.max_minibatch_size = 4;

opts{1}.invariants.time.invariance = 'blurred';
opts{1}.invariants.time.size = opts{1}.banks.time.size;
opts{1}.invariants.time.T = T_phi;

opts{1}.etc.is_waitbar_shown = false;

for m = [2, 3]
    opts{m}.banks.time.max_Q = Qs(m);
    opts{m}.banks.time.size = opts{1}.banks.time.size;
    opts{m}.banks.time.T = T_psi;

    opts{m}.invariants.time.invariance = 'blurred';
    opts{m}.invariants.time.T = T_phi;
    opts{m}.invariants.time.size = opts{1}.banks.time.size;
end

opts{4}.invariants.time.invariance = 'blurred';
opts{4}.invariants.time.T = T_phi;
opts{4}.invariants.time.size = opts{1}.banks.time.size;
opts{4}.invariants.time.subscripts = 1;

archs = sc_setup(opts);

for signal_id = 1:n_signals
    tic();
    N = signal_lengths(signal_id);
    x = randn(N, 1);
    S = sc_propagate(x, archs);
    
    % Get first order.
    S1_mat = S{1+1}{1}{1}.data;

    % Get second order.
    S2_mat = [S{1+2}{1}{1}.data{:}];

    % Get third order.
    J3 = length(S{1+3}{1}{1}.data);
    S3_cell = cell(J3, 1);
    for j3 = 1:J3
        S3_cell{j3} = [S{1+3}{1}{1}.data{j3}{:}];
    end
    S3_mat = [S3_cell{:}];

    S_mat = cat(2, S1_mat, S2_mat, S3_mat);
    
    delta_t = toc();
    delta_ts(signal_id, 1) = delta_t;
    fprintf('Signal length: %5.1e\n', N);
    fprintf('Elapsed time: %05.3f seconds\n', delta_t);
    fprintf('Speed: %dx real time\n', floor(N/(delta_t*200)));
    fprintf('\n');
end



% PART 2. WITH ACCELERATION.

disp('************************************************************')
disp('PART 2: ACCELERATED THIRD-ORDER SCATTERING')

clear opts; clear archs; 

opts = cell(1, 4);
opts{1}.banks.time.T = T_psi;
opts{1}.banks.time.max_Q = Qs(1);
opts{1}.banks.time.max_scale = Inf;
opts{1}.banks.time.size = 4*T_psi;
opts{1}.banks.time.is_chunked = true;
opts{1}.banks.time.is_unchunked = false;
opts{1}.banks.time.is_windowed = true;
opts{1}.banks.time.max_minibatch_size = 4;

opts{1}.invariants.time.invariance = 'blurred';
opts{1}.invariants.time.size = opts{1}.banks.time.size;
opts{1}.invariants.time.T = T_phi;

opts{1}.etc.is_waitbar_shown = false;

for m = [2, 3]
    opts{m}.banks.time.max_Q = Qs(m);
    opts{m}.banks.time.size = opts{1}.banks.time.size;
    opts{m}.banks.time.T = T_psi;

    opts{m}.invariants.time.invariance = 'blurred';
    opts{m}.invariants.time.T = T_phi;
    opts{m}.invariants.time.size = opts{1}.banks.time.size;
end

opts{4}.invariants.time.invariance = 'blurred';
opts{4}.invariants.time.T = T_phi;
opts{4}.invariants.time.size = opts{1}.banks.time.size;
opts{4}.invariants.time.subscripts = 1;

archs = sc_setup(opts);

for signal_id = 1:n_signals
    tic();
    N = signal_lengths(signal_id);
    x = randn(N, 1);
    S_batches = sc_propagate(x, archs);
    
    % Custom post-processing loop: fused reduction, unchunking, and formatting
    nBatches = size(S_batches, 1);
    S_cell = cell(nBatches, 3);
    t_start = 1 + 0.25*size(S_batches{1,2}{1}.data, 1);
    t_stop = 0.75*size(S_batches{1,2}{1}.data, 1);

    for batch_id = 1:nBatches

        % First order.
        S1_tensor = S_batches{batch_id, 1+1}{1}.data(t_start:t_stop, :, :);
        S_cell{batch_id, 1} = reshape(S1_tensor, ...
            [size(S1_tensor, 1)*size(S1_tensor, 2), size(S1_tensor, 3)]);

        % Second order.
        S2_temp = cellfun( ...
            @(x) reshape(x(t_start:t_stop, :, :), ...
            [(t_stop-t_start+1)*size(x, 2), size(x, 3)]), ...
            S_batches{batch_id,1+2}{1}.data, 'UniformOutput', false);
        S_cell{batch_id, 2} = [S2_temp{:}];

        % Third order.
        J3 = length(S_batches{1,1+3}{1}.data);
        S3_temp = cell(1, J3);
        for j3 = 1:J3
            S3_j3 = cellfun( ...
                @(x) reshape(x(t_start:t_stop, :, :), ...
                [(t_stop-t_start+1)*size(x, 2), size(x, 3)]), ...
                S_batches{batch_id,1+3}{1}.data{j3}, 'UniformOutput', false);
            S3_temp{j3} = [S3_j3{:}];
        end
        S_cell{batch_id, 3} = [S3_temp{:}];
    end

    S_mats = cell(1, 3);
    for layer_id = 1:3
        S_mats{layer_id} =  cat(1, S_cell{:, layer_id});
    end
    S_mat = [S_mats{:}];

    delta_t = toc();
    delta_ts(signal_id, 2) = delta_t;
    fprintf('Signal length: %5.1e\n', N);
    fprintf('Elapsed time: %05.3f seconds\n', delta_t);
    fprintf('Speed: %dx real time\n', floor(N/(delta_t*200)));
    fprintf('\n');
end


%%
