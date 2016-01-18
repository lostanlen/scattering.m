function Y = sparse_backward(X,dicts)
% Given a set of dictionaries (D) and the coefficients of a signal on this
% dictioanry space (alpha), we reconstruct the original signal as Y=D alpha
% Note that D=dicts{lambda2}, alpha = X{lambda2}

nLambda2s = length(X.data);

for l=dicts.lambda_start:nLambda2s
    Y.data{l} = dicts.backward{l} *X.data{l};
end
