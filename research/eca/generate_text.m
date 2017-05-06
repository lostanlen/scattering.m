% Replace these paths
toolbox_path = '~/scattering.m';
audio_path = '~/datasets/eca/bach1.wav';

addpath(genpath('scattering.m'));

%%
Q1 = 12; % number of filters per octave at first order
T = 2^10; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'morlet';
archs = eca_setup(Q1, T, modulations, wavelets);
N = archs{1}.banks{1}.spec.size;

%%
% set to Inf to get all lines
% set to NaN ("not a number") to get all lines with >0 ppm
nLines = Inf; 
[y, sample_rate] = eca_load(audio_path);
padding_length = ceil(length(y)/N) * N - length(y);
y = cat(1, y, zeros(padding_length, 1));
y_chunks = eca_split(y, N);
S = sc_propagate(y_chunks, archs);
[text, S_sorted_paths] = eca_text(archs, audio_path, nLines);
disp(text)