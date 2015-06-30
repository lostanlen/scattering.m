%% Loading of target waveform
[original_waveform,sample_rate] = ...
    audioread_compat('../dafx15/sequenza_at3min42.wav');
start = 1;
nSamples = 2^18 * 7/4;
target_signal = original_waveform((start-1) + (1:nSamples));
J = 17;
T = 2^J;

%% Creation of wavelet filterbank
opts{1}.time.size = length(target_signal);
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 4096;
opts{1}.time.has_duals = true;

opts{2}.time.T = T;
opts{2}.time.has_duals = true;

archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

%% Computation of invariant scattering coefficients
target_S = sc_propagate(target_signal,archs);

%% Reconstruction
rec_opt.verbosity_period = 1;
nIterations = 50;
[rec_signal,rec_summary] = ...
    sc_reconstruct(target_S,archs,rec_opt,nIterations);

%% Export
audiowrite(['sequenza_spiral_J',num2str(J),'.wav'],rec_signal,sample_rate);
save(['sequenza_spiral_J',num2str(J)]);