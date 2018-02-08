% The integer method_index specifies the scattering architecture.
% 1: first-order scattering only
% 2: with plain, second-order coefficinets
% 3: with joint coefficients (up to the scale of 1 octave)
% 4: same, up to the scale of 2 octaves
% 5: same, up to the scale of 4 octaves

function mlsp_synthesize_scattering(y, method_index)
N = 65536;
sample_rate =  22050;
T = N/8;

% Convert to mono
if size(y, 2) == 2
    y = 0.5 * sum(y, 2);
end

% Pad or trim to length N.
if N > 0
    if length(y) < N
        y = cat(1, y, zeros(N - length(y), 1));
    else
        y = y(1:N);
    end
end

opts{1}.time.size = N;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 64];
opts{1}.time.is_chunked = false;


if method_index>1
    opts{2}.time.T = T;
    opts{2}.time.max_scale = Inf;
    opts{2}.time.handle = @morlet_1d;
    opts{2}.time.sibling_mask_factor = 2;
    opts{2}.time.max_Q = 1;
    opts{2}.time.has_duals = true;
    opts{2}.time.U_log2_oversampling = 1;
end
if method_index>2
    opts{2}.gamma.T = 2^(method_index-3) * opts{1}.time.nFilters_per_octave;
    opts{2}.gamma.handle = @morlet_1d;
    opts{2}.gamma.nFilters_per_octave = 2;
    opts{2}.gamma.max_Q = 1;
    opts{2}.gamma.cutoff_in_dB = 1.0;
    opts{2}.gamma.has_duals = true;
    opts{2}.gamma.U_log2_oversampling = 1;
end

archs = sc_setup(opts);

%% Initialization
cutoff_frequency = 500; % in Hertz
cutoff_index = round(cutoff_frequency * N/sample_rate);
range = linspace(0,1,N-cutoff_index+1).';
alpha = 20;
initial_signal_ft = zeros(N,1);
initial_signal_ft(cutoff_index:end) = ...
    range.^2 .* exp(-alpha*range) .* randn(length(range),1);
initial_signal = real(ifft(initial_signal_ft));
initial_signal = initial_signal - mean(initial_signal);
initial_signal = initial_signal * norm(target_signal)/norm(initial_signal);
initial_signal = initial_signal + mean(target_signal);

%%
rec_opt.is_regularized = false;
rec_opt.initial_signal = initial_signal;
rec_opt.verbosity_period = 1;
rec_opt.signal_display_period = 10;
rec_opt.nIterations = 100;
rec_opt.initial_learning_rate = 0.1;
rec_opt.momentum = 0.9;
rec_opt.bold_driver_accelerator = 1.1;
rec_opt.bold_driver_brake = 0.5;
rec_opt.is_verbose = true;
signal = sc_reconstruct(target_signal,archs,rec_opt);

switch method_index
    case 1
        audiowrite('accipiter_firstorder.wav',signal,sample_rate);
    case 2
        audiowrite('accipiter_plain.wav',signal,sample_rate);
    case 3
        audiowrite('accipiter_joint1oct.wav',signal,sample_rate);
    case 4
        audiowrite('accipiter_joint2oct.wav',signal,sample_rate);
    case 5
        audiowrite('accipiter_joint4oct.wav',signal,sample_rate);
end
end
