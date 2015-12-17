% dict is a structure with three fields:
% * lambda_start
% * forward
% * backward
function alpha = sparse_forward(Y, dict)

nLambda2s = length(Y.data);

for lambda2_index = dict.lambda_start:L2
    next_sub_Y{lambda2_index} = ...
        dict.forward{lambda2_index} * Y.data{lambda2_index};
end 
end