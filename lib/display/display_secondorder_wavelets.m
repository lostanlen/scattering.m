function Y2 = display_secondorder_wavelets(archs, fraction)
if nargin<2
    fraction = 1/5;
end
%% Initialization with silence
N = archs{1}.banks{1}.spec.size;
signal = zeros(N,1);

%% Initialization of scattering layers
nLayers = length(archs) - 1;
S = cell(1,1+nLayers);
U = cell(1,1+nLayers);
Y = cell(1,1+nLayers);

U{1+0} = initialize_variables_auto(size(signal));
U{1+0}.data = signal;

%% Empty scalogram
Y{1} = U_to_Y(U{1+0}, archs{1}.banks);
U{1+1} = Y_to_U(Y{1}{end}, archs{1}.nonlinearity);

%% A Dirac is set within the scalogram structure
if iscell(U{1+1})
    U{1+1}{1}.data{round(fraction*end)}(end/2) = 1;
else
    U{1+1}.data{round(fraction*end)}(end/2) = 1;
end

%% Second-order scattering
if iscell(U{1+1})
    Y2 = U_to_Y(U{1+1}{1}, archs{2}.banks);
else
    Y2 = U_to_Y(U{1+1}, archs{2}.banks);
end
end