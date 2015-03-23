function scalogram_opt = default_auditory(N,sample_rate,Q)
min_frequency_in_Hertz = 50; % 50 Hz is the minimum audible frequency
max_scale_in_seconds = 0.1; % 100ms is the minimal duration between events

%%
scalogram_opt.time.T = pow2(nextpow2(sample_rate / min_frequency_in_Hertz));
scalogram_opt.time.max_Q = Q;
scalogram_opt.time.max_scale = ...
    pow2(nextpow2((max_scale_in_seconds*sample_rate)-1));
scalogram_opt.time.size = N;
end