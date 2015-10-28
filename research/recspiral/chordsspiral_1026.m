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

if strcmp(arch_type, 'joint') || strcmp(arch_type, 'spiral')
    opts{2}.gamma.T = 4 * opts{1}.time.nFilters_per_octave;
    opts{2}.gamma.handle = @morlet_1d;
    opts{2}.gamma.nFilters_per_octave = 2;
    opts{2}.gamma.max_Q = 1;
    opts{2}.gamma.cutoff_in_dB = 3.0;
    opts{2}.gamma.has_duals = true;
    opts{2}.gamma.U_log2_oversampling = 2;
    opts{2}.gamma.S_log2_oversampling = 2;
end

if strcmp(arch_type, 'spiral')
    opts{2}.j.invariance = 'bypassed';
    opts{2}.j.has_duals = true;
    opts{2}.j.handle = @finitediff_1d;
end

archs = sc_setup(opts);

%% Options for the reconstruction
str = struct('snapshot_period', 10);
reconstruction_opt = fill_reconstruction_opt(str);

%%
sc_reconstruct(target_signal, archs, reconstruction_opt);
