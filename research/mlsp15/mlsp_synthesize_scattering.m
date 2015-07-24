% The integer method_index specifies the scattering architecture.
% 1: first-order scattering only
% 2: with plain, second-order coefficinets
% 3: with joint coefficients (up to the scale of 1 octave)
% 4: same, up to the scale of 2 octaves
% 5: same, up to the scale of 4 octaves

function mlsp_synthesize_scattering(method_index)
N = 65536;
sample_rate =  22050;
T = N/8;

opts{1}.time.size = N;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 64];
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

%%
[target_signal] = audioread('accipiter_original.wav');
[target_S,target_U,target_Y] = sc_propagate(target_signal,archs);

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
rec_opt.verbosity_period = 1;
rec_opt.signal_display_period = 10;
nIterations = 100;
rec_opt.learning_rate = 0.1;
rec_opt.momentum = 0.9;
rec_opt.bold_driver_accelerator = 1.1;
rec_opt.bold_driver_brake = 0.5;
[signal,summary] = ...
    sc_reconstruct(target_S,archs,rec_opt,nIterations,initial_signal);
switch method_index
    case 1
        firstorder_summary = summary;
        save('accipiter_summary_firstorder','firstorder_summary');
        audiowrite('accipiter_firstorder.wav',signal,sample_rate);
        target_summary.U = target_U;
        target_summary.S = target_S;
        target_summary.signal = target_signal;
        save('accipiter_target','target_summary');
    case 2
        plain_summary = summary;
        save('accipiter_summary_plain','plain_summary');
        audiowrite('accipiter_plain.wav',signal,sample_rate);
    case 3
        joint1oct_summary = summary;
        save('accipiter_summary_joint1oct','joint1oct_summary');
        audiowrite('accipiter_joint1oct.wav',signal,sample_rate);
    case 4
        joint2oct_summary = summary;
        save('accipiter_summary_joint2oct','joint2oct_summary');
        audiowrite('accipiter_joint2oct.wav',signal,sample_rate);
    case 5
        joint4oct_summary = summary;
        save('accipiter_summary_joint4oct','joint4oct_summary');
        audiowrite('accipiter_joint4oct.wav',signal,sample_rate);
end
end
