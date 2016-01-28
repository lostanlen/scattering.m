
% [Y,initnLambda]=generate_allInstrumentsDb();
% disp('save DB')
% save('./allInstrumentsDB.mat','Y','initnLambda');

load('../../../../data/Data_allinstrumentsNosat.mat');%get Y and initnLambda

%% Compute the dictionaries
 initnLambda = 1;
 dicts.lambda_start = initnLambda;
 k_dim_coeff = 1;%percentage of dim that we want for the atoms of the dictionary

[dicts] = learn_Dictionaries(Y,dicts.lambda_start,k_dim_coeff);

save('./Dictionarylambda_normdata.mat','dicts');

return


load('./Dictionarylambda.mat');
% k_dim_coeff = 0.8;%percentage of dim that we want for the atoms of the dictionary
% 
% [dicts] = learn_Dictionaries(Y,dict.lambda_start,k_dim_coeff);
% save('./Dictionarynolambdanosquared.mat','dicts');

for lambda2=initnLambda:length(dicts.backward)
    h=visualizing_dict(dicts.backward,lambda2);
    save(h,['./dicts_' num2str(lambda2) '.png']);
end 

return;

%Checking how sparse the representation is
%take last lambda2
params.modeD=0; %atoms with norm 1
params.mode=1; %l1 norm on the coefs alpha
params.lambda=0.001;
params.iter = 3000;
%params.batchsize=512;
params.numThreads=-1; % number of threads
params.verbose=true;


lambda2=4;%length(dicts.backward);

D = dicts.backward{lambda2};
alpha_real=mexLasso(real(Y{lambda2}),real(D),params);

[~,peak_lambda1s] = sort(sum(abs(alpha_real)>0.1,2),1,'descend');

imagesc(real(d(:,peak_lambda1s)));



alpha_complex=mexLasso(imag(Y{lambda2}),imag(D),params);

%postproc
 IndexP = randperm(size(Y{lambda2},2));
 
 data =real( Y{lambda2}(:,IndexP));
 %data = data-mean(data(:));
 %data = data/max(data(:));
 
norm_data = sqrt(sum(data.^2,1));
data = data./repmat(norm_data,[size(data,1) 1]);
 
 
 params.K = size(data,1);%squared dict
 D_real=mexTrainDL_Memory(real(data),params);
       

return;




alphas = sparse_forward(Y, dicts, initnLambda);
Ytilde = sparse_backward(alphas, dicts, initnLambda);


% check the overall error
disp('Check the error in the approximation of the DB:')
flat = @(x)x(:);
errorComp = @(x)sum(x.^2,1);
for lambda2_index = initnLambda:nLambda2s
  
    aux = dicts{lambda2_index}.backward*alpha.data{lambda2_index};
    errorConstr=mean(errorComp(aux - Y2{lambda2_index}));
    disp(['err on cosntr Y(' num2str(lambda2_index) ')=' num2str(errorConstr) ]);
    
    errorY=mean(errorComp(Ytilde.data{lambda2_index} - Y2{lambda2_index}));
    disp(['err on Y(' num2str(lambda2_index) ')=' num2str(errorY) ]);
end


%% Show Y and DX for 7th lambda2
% lambda2 = 7;
% 
% range = 1:4900;
% subplot(211);
% imagesc(Y2{lambda2}(:,range));
% subplot(212);
% imagesc(dicts{lambda2}*alphas{lambda2}(:,range))






