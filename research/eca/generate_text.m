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

%%
nLines = NaN; % set to NaN ("not a number") to get all lines
[text, S_sorted_paths] = eca_text(archs, audio_path, nLines);
disp(text)