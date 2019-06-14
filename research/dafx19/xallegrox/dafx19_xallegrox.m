%%
N = 131072;
J = 11;
T = 2^J;

clear opts;
opts{1}.time.size = 65536;
opts{1}.time.T = 2^10;
opts{1}.time.nFilters_per_octave = 24;
opts{1}.time.gamma_bounds = ...
    [1+opts{1}.time.nFilters_per_octave*3 ...
    opts{1}.time.nFilters_per_octave*7];
opts{1}.time.max_Q = 24;
opts{1}.time.is_chunked = true;
opts{1}.time.max_scale = Inf;

archs = sc_setup(opts);

%%
wav_dir = '/Users/vl238/datasets/dafx19';
wav_name = '02. Lorenzo Senni - XAllegroX Hecker Scattering.m Sequence [Warp Records]';
wav_path = fullfile(wav_dir, [wav_name, '.wav']);
[y, sr] = audioread(wav_path);

start_time = 337.0;
duration = 60;
stop_time = start_time + duration;
y_excerpt = y(round(start_time*sr):round(stop_time*sr), 1);
plot(y_excerpt);

[S, U] = sc_propagate(y_excerpt, archs);
U = sc_unchunk(U);
Usc = display_scalogram(U{1+1});

%
nfo = opts{1}.time.nFilters_per_octave;


%%
denominator = 8e3;
t_range = 1:286200;
imagesc(log(1*max(Usc(64:78,3*length(t_range)+t_range)/denominator, 1)));
%imagesc(log1p(Usc(64:78,950000:1250000)/denominator)); 
colormap rev_magma
%%
