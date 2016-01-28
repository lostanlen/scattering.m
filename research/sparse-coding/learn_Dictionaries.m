function [dict,E]=learn_Dictionaries(Y,initnLambda,coeff)
% This function finds the dictioanries for each data set in the Y cell. We
% assume the following dimensions:
% * Y{lambda2}: Nxlambda1 where N is the number of exemplars and lambda1
% their dimension
% * initnLambda: where to start the learning of the dictionaries
% * coef: related to the number of atoms in the dictionary: #atoms = coef*dim(Dict)
%        always lower than 1. 
% The output is a cell D where each element: 
% * D{lmabda2}: lambda1xB, where B is the number of atoms. B < lambda1, for
% all cells

L2 = length(Y);

params.modeD=0; %atoms with norm 1
params.mode=1; %l1 norm on the coefs alpha
params.lambda=0.15;
params.iter = 3000;
%params.batchsize=512;
params.numThreads=-1; % number of threads
params.verbose=false;


%Obtain dictionary backward: Y=D X
for l=L2:-1:initnLambda
    disp(['l=' num2str(l)]);
    [l1,~]=size(Y{l});
  
  %contiguous patches are very similar, thus we need to randomize their
    %position (since it is using minibatch)
    IndexP = randperm(size(Y{l},2));
    
    %want to compute real dictionaries, so we stack the real and imaginary
    %part
    data2 = cat(2,real(Y{l}(:,IndexP)),imag(Y{l}(:,IndexP)));
    
    %Normalize the atoms before training: our dict. is going to be normalized 
    norm_data = sqrt(sum(data2.^2,1));
    data2 = Y{l}./repmat(norm_data,[size(Y{l},1) 1]);
    norm_data=[]; %free memory
    IndexP = [];
    %size of dicts depend on the dims of the atoms
    params.K=round(l1*coeff); %we want less (or equal) atoms than dimensions
    
    % get dictionary
    D=mexTrainDL_Memory(data2,params);
        
    dict.backward{l} = D; 
    visualizing_dict(dict.backward,l);
   
%% in case we want to compute the alphas...    
%     alpha_real=mexLasso(real(Y{l}),D,params);
%     E(l)=norm(D*alpha_real-Y{l})+params.lambda*(abs(alpha_real)+abs(alpha_real));
% 

%% previous learning algo
    % [dict.backward{l},X,err]=learn_dict(Y{l},K,n,N);
%     E(l,1)=err(end);
%     E(l,2)=norm(dict.backward{l}*X-Y{l})/norm(dict.backward{l}*X)  %relative err
%      
%     alphas{l} = X;
%     dict.forward{l} = pinv(dict.backward{l});
%     dict.forward_conjugate{l} = dict.backward{l}';
end 