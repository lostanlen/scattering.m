function Y = sparse_backward(X,dicts,initnLambda)
% Given a set of dictionaries (D) and the coefficients of a signal on this
% dictioanry space (alpha), we reconstruct the original signal as Y=D alpha
% Note that D=dicts{lambda2}, alpha = X{lambda2}

L2 = length(X);

for l=initnLambda:L2
    Y{l} = dicts{l}*X{l};
end