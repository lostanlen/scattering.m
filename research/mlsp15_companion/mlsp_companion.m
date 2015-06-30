addpath(genpath('~/MATLAB/scattering.m/'))
folder_path = '~/mlsp2015/dataset22k';
file_infos = dir(folder_path);
file_index = 1;
method_index = 3;

%% Skip hidden files
first_character = char('.');
while first_character==char('.')
    file_index = file_index + 1;
    file_name = file_infos(file_index).name;
    first_character = char(file_name(1));
end
file_infos = file_infos(file_index:end);
nFiles = length(file_infos);

%%
sample_rate = 22050;
N = 65536;
waveforms = zeros(N,nFiles);
offsets = zeros(1,nFiles);
offsets(4) = 8 * sample_rate;
offsets(7) = 1 * sample_rate;


for file_index = 1:nFiles
    file_name = file_infos(file_index).name;
    file_path = fullfile(folder_path,file_name);
    original_waveform = audioread_compat(file_path);
    offset = offsets(file_index);
    if N<length(original_waveform)
        waveforms(:,file_index) = original_waveform(offset+(1:N));
    else
        assert(offset==0);
        padding_zeros = zeros(N-length(original_waveform),1);
        waveforms(:,file_index) = ...
            cat(1,original_waveform,padding_zeros);
    end
end


%%
T = N/8;
opts{1}.time.size = N;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 128];
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
    opts{2}.gamma.T = 4 * opts{1}.time.nFilters_per_octave;
    opts{2}.gamma.handle = @morlet_1d;
    opts{2}.gamma.nFilters_per_octave = 2;
    opts{2}.gamma.max_Q = 1;
    opts{2}.gamma.cutoff_in_dB = 1.0;
    opts{2}.gamma.has_duals = true;
    opts{2}.gamma.U_log2_oversampling = 1;
end
archs = sc_setup(opts);

%% Forward scattering
for file_index = 1:nFiles
    target_signal = waveforms(:,file_index);
    [target_S,target_U,target_Y] = sc_propagate(target_signal,archs);
    
    %% Initialization
    initial_signal = generate_pink_noise(N);
    initial_signal = initial_signal - mean(initial_signal);
    initial_signal = initial_signal * norm(target_signal)/norm(initial_signal);
    initial_signal = initial_signal + mean(target_signal);
    
    %% Reconstruction
    rec_opt.verbosity_period = 1;
    rec_opt.signal_display_period = 10;
    nIterations = 50;
    rec_opt.learning_rate = 0.1;
    rec_opt.momentum = 0.9;
    rec_opt.bold_driver_accelerator = 1.1;
    rec_opt.bold_driver_brake = 0.5;
    [signal,summary] = ...
        sc_reconstruct(target_S,archs,rec_opt,nIterations,initial_signal);
    
    %% Export
    file_name = file_infos(file_index).name;
    file_name = file_name(1:(end-4)); % remove .WAV extension
    switch method_index
        case 1
            firstorder_summary = summary;
            suffix = 'firstorder';
            target_summary.U = target_U;
            target_summary.S = target_S;
            target_summary.signal = target_signal;
            save([file_name,'_target'],'target_summary');
        case 2
            plain_summary = summary;
            suffix = 'plain';
        case 3
            joint_summary = summary;
            suffix = 'joint';
    end
    
    export_audio_name = [file_name,'_',suffix,'.wav'];
    audiowrite(export_audio_name,signal,sample_rate);
    export_summary_name = [file_name,'_summary_',suffix,'.mat'];
    save(export_summary_name,[suffix,'_summary']);
end