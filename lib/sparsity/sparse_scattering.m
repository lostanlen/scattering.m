function [S,U,Y] = sparse_scattering(signal, archs, sparsifier)
%% Initialization of networks S, U, and Y.
% S and U are zero-based ; Y is one-based.
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1, nLayers);
Y = cell(1, nLayers);

U{1+0} = initialize_U(signal, archs{1}.banks{1});

% First wavelet transform
Y{1} = U_to_Y(U{1+0}, archs{1}.banks);

% First low-pass filter
S{1+0} = Y_to_S(Y{1}, archs{1});

% First complex modulus
U{1+1} = Y_to_U(Y{1}{end}, archs{1}.nonlinearity);

% Second wavelet transform
Y{2} = U_to_Y({1+1}, archs{2}.banks);

% Sparse projection to dictionary atoms
 Y{2}{end+1} = Y{2}{end};
nLambda2s = length(Y{2}.data);
for lambda2_index = 1:nLambda2s
    % Real part
    Y_real = real(Y{2}.data{lambda2_index});
    Z_real = mexLasso(Y_real, sparsifier.D{lambda2}, params);
    
    % Imaginary part
    Y_imag = imag(Y{2}.data{lambda2_index});
    Z_imag = mexLasso(Y_imag, sparsifier.D{lambda2}, params);
    
    Y{2}{end+1}.data{lambda2} = Z_real + 1i * Z_imag;
end

% Second low-pass filter
S{1+1} = Y_to_S(Y{2}, archs{2});

% Second complex modulus
U{1+2} = Y_to_U(Y{2}{end}, archs{2}.nonlinearity);

% Third low-pass filter
Y{3} = U(1+2);
S{1+2} = Y_to_S(Y{3}, archs{3});
end

