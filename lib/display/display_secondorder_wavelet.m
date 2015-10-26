function Y2 = display_secondorder_wavelet(archs, fraction)
if nargin<2
    fraction = 1/5;
end
%% Initialization with silence
N = archs{1}.banks{1}.spec.size;
signal = zeros(N,1);

%% Initialization of scattering layers
nLayers = length(archs);
S = cell(1,1+nLayers);
U = cell(1,1+nLayers);
Y = cell(1,1+nLayers);

U{1+0} = initialize_variables_auto(size(signal));
U{1+0}.data = signal;

%% Emptys scalogram
Y{1} = U_to_Y(U{1+0}, archs{1});
U{1+1} = Y_to_U(Y{1}{end}, archs{1});

%% A Dirac is set within the scalogram structure
U{1+1}.data{round(fraction*end)}(end/2) = 1;

%% Second-order scattering
Y2 = U_to_Y(U{1+1}, archs{2});
end