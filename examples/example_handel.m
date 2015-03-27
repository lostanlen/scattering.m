% In this script, we load a 8-second signal and perform second-order scattering
% on it.
% First, we display the "scalogram"
% We display the "scattergram", that is, the energy of second-order coefficients
% over time for a fixed modulation scale (here about 1 second), as a function of
% the acoustic frequency.

%% Load demo signal
load handel;
N = 65536; % length of signal must be a power of 2
Q = 8; % quality factor
signal = y(1:N);

%% Take default values for auditory transform
opts{1} = default_auditory(length(signal),Fs,Q);
% This line adds a second-order transform on top
opts{2}.time = struct();

%% Build "architectures" (filter banks)
archs = sc_setup(opts);

%% Compute scattering representation
[S,U,Y] = sc_propagate(signal,archs);

%% Display scalogram (wavelet transform modulus)
display_scalogram(U{1+1});
colormap hot;

%% Display second-order spectrum at given scale
modulation_scale_index = 10;
scattergram = U{1+2}{1}.data{modulation_scale_index}.';
imagesc(scattergram);