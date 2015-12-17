function alpha = sparse_forward(Y,D,initnLambda)

L2 = length(Y);
for l=initnLambda:L2

    %Compute the conjugate of the dictionary: alpha(\lambda2) = D^* S(\lambda2)
    conjD = D{l}';
    alpha{l} = conjD*Y{l};
end 