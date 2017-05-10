% Replace these paths
toolbox_path = '~/scattering.m';
folder = '~/datasets/eca';

addpath(genpath(toolbox_path));

%%
Q1 = 12; % number of filters per octave at first order
T = 2^10; % amount of invariance with respect to time translation
% The modulation setting is either 'none', 'time', or 'time-frequency'
% The wavelets setting is either 'morlet' or 'gammatone'
modulations = 'time-frequency';
wavelets = 'morlet';
archs = eca_setup(Q1, T, modulations, wavelets);

%%
% set to Inf to get all lines
% set to NaN ("not a number") to get all lines with >0 ppm
nLines = Inf; 
eca_text_dir(archs, folder, nLines)