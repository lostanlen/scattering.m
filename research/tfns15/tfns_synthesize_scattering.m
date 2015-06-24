N = 65536;
sample_rate =  22050;
T = N/8;

opts{1}.time.size = N;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 64];

opts{2}.time.T = T;
opts{2}.time.max_scale = Inf;
opts{2}.time.handle = @morlet_1d;
opts{2}.time.sibling_mask_factor = 2;
opts{2}.time.max_Q = 1;
opts{2}.time.has_duals = true;

opts{2}.gamma.T = 1 * opts{1}.time.nFilters_per_octave;
opts{2}.gamma.handle = @morlet_1d;
opts{2}.gamma.nFilters_per_octave = 2;
opts{2}.gamma.max_Q = 1;
opts{2}.gamma.cutoff_in_dB = 1.0;
opts{2}.gamma.has_duals = true;

opts{2}.j.invariance = 'bypassed';
opts{2}.j.T = 4;
opts{2}.j.phi_bw_multiplier = 1;
opts{2}.j.has_duals = true;
opts{2}.j.handle = @morlet_1d;

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
spiral_summary = summary;
save('accipiter_summary_spiral','spiral_summary');
audiowrite('accipiter_spiral.wav',signal,sample_rate);

%%
multiplier = 100;
colormap rev_gray;
scalogram = display_scalogram(U{1+1});
scalogram = scalogram(:,1:32768);
scalogram = scalogram / max(scalogram(:));
logscalogram = log(1+multiplier*scalogram);
imagesc(logscalogram); drawnow;
size_multiplier = 4;
axis off;
set(gcf,'Units','centimeters');
set(gcf,'Position',[5.0 5.0 size_multiplier*8.6 size_multiplier*2.0])
axis off;

%%
export_fig('accipiter_spiral.png','-transparent');
    