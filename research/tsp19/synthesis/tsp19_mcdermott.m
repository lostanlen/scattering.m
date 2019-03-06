% Script arguments:
% * audio_name_str


% Define parameters.
synthesis_parameters_2011_Neuron_paper;
P.orig_sound_filename = [audio_name_str, '.wav'];
P.orig_sound_folder = 'media/';
P.output_folder = 'media/';
P.constraint_set.sub_kurt = 1;
P.leave_out_convergence_criterion_db = inf;
P.compression_option=0;
P.audio_sr = 20000;
P.hi_audio_f = 10000;
P.write_norm_orig = false;
P.display_figures = false;
P.save_figures = false;
P.max_orig_dur_s = 2.9722;
P.desired_synth_dur_s = 2.9722;
P.N_audio_channels = 72;
P.use_more_audio_filters = 1;
P.use_more_mod_filters=1;


% Run synthesis
run_synthesis(P);
