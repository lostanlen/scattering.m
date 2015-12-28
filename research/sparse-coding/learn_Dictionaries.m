function [dict,E]=learn_Dictionaries(Y,initnLambda,coeff)
% This function finds the dictioanries for each data set in the Y cell. We
% assume the following dimensions:
% * Y{lambda2}: Nxlambda1 where N is the number of exemplars and lambda1
% their dimension
% * initnLambda: where to start the learning of the dictionaries
% * coef: related to the number of atoms in the dictionary: #atoms =coef*dim(Dict)
%        always lower than 1. 
% The output is a cell D where each element: 
% * D{lmabda2}: lambda1xB, where B is the number of atoms. B < lambda1, for
% all cells

L2 = length(Y);

%Obtain dictionary backward: Y=D X
for l=initnLambda:L2
    disp(['l=' num2str(l)]);
    [l1,N]=size(Y{l});
    K = round(l1*coeff); %we want less atoms than dimensions
   % [D{l},X,err] = perform_dictionary_learning(Y{l}+eps,options);
    [dict.backward{l},X,err]=learn_dict(Y{l},K,N);
    E(l)=min(err)
    
    dict.forward{l} = pinv(dict.backward{l});
    dict.forward_conjugate{l} = dict.backward{l}';
end 