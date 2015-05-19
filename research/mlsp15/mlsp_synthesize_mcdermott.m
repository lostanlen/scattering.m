addpath(genpath('mcdermott_toolbox'));
synthesis_parameters_2011_Neuron_paper;
P.orig_sound_filename = 'accipiter_original.wav';
P.orig_sound_folder = '';
P.output_folder = 'mcdermott_toolbox/Output_Folder/';
run_synthesis(P);

%%
[mcdermott_waveform,sample_rate] = ...
    audioread('mcdermott_toolbox/Output_Folder/accipiter_10111110111.wav');
signal = mcdermott_waveform(1:32768);
audiowrite('accipiter_mcdermott.wav',signal,sample_rate);

N = 32768;
T = N/4;

opts{1}.time.size = N;
opts{1}.time.T = T;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 64];

archs = sc_setup(opts);
[mcdermott_summary.S,mcdermott_summary.U] = sc_propagate(signal,archs);
save('accipiter_summary_mcdermott');