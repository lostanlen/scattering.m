function [D,E]=learn_Dictionaries(Y,initnLambda)
% This function finds the dictioanries for each data set in the Y cell. We
% assume the following dimensions:
% * Y{lambda2}: Nxlambda1 where N is the number of exemplars and lambda1
% their dimension
% 
% The output is a cell D where each element: 
% * D{lmabda2}: lambda1xB, where B is the number of atoms. B < lambda1, for
% all cells

L2 = length(Y);

options.learning_method = 'mod';%algorithm
options.use_mex = 1;

disp('Learning Dictionaries:')
for l=initnLambda:L2
    disp(['l=' num2str(l)]);
    [l1,N]=size(Y{l});
    options.K = l1;%round(l1/1.5); %we want less atoms than dimensions
    [D{l},X,err] = perform_dictionary_learning(Y{l},options);

   disp(['Error:' num2str(norm(D{l}*X-Y{l}))]);
    E(l)=max(err);
end 