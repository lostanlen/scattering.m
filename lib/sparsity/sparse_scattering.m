function [S,U,Y] = sparse_scattering(signal, archs, dicts)
%% Initialization of networks S, U, and Y.
% S and U are zero-based ; Y is one-based.
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1, nLayers);
Y = cell(1, nLayers);

U{1+0} = initialize_U(signal, archs{1}.banks{1});

end

