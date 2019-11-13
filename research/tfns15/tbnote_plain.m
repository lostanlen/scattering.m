%% Loading of target waveform
[original_waveform,sample_rate] = ...
    audioread_compat('../dafx15/sequenza_at3min42.wav');
start = 5.75*2^16;
nSamples = 2^16;
target_signal = original_waveform((start-1) + (1:nSamples));
T = 2^15;

%% Creation of wavelet filterbank
opts{1}.time.size = length(target_signal);
opts{1}.time.is_chunked = false;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.gamma_bounds = [1 128];
opts{1}.time.T = T;
opts{1}.time.max_scale = 4096;
opts{1}.time.has_duals = true;

opts{2}.time.T = T;
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.max_Q = 1;
opts{2}.time.max_scale = Inf;
opts{2}.time.nFilters_per_octave = 1;
opts{2}.time.has_duals = true;

archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

%% Computation of invariant scattering coefficients
target_S = sc_propagate(target_signal,archs);

%% Reconstruction
rec_opt.verbosity_period = 1;
rec_opt.nIterations = 50;
rec_signal = sc_reconstruct(target_signal,archs,rec_opt);

%% Export
audiowrite('tbnote_plain.wav',rec_signal,sample_rate);
save('tbnote_plain');
