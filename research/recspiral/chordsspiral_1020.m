file_path = 'chords_original.wav';
[full_waveform, sample_rate] = audioread_compat(file_path);
N = 2^16;
target_signal = full_waveform(1:N);
arch_type = 'spiral';

%% Options for the scattering transform
T = N/2;
opts{1}.time.T = T;
opts{1}.time.size = N;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 128];
opts{1}.time.phi = 'gamma';

opts{2}.time.T = T;
opts{2}.time.max_scale = Inf;
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.sibling_mask_factor = 2;
opts{2}.time.max_Q = 1;
opts{2}.time.has_duals = true;
opts{2}.time.U_log2_oversampling = 2;
opts{2}.time.phi = 'gamma';

archs = sc_setup(opts);