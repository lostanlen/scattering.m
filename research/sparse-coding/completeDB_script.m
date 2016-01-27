
% [Y,initnLambda]=generate_allInstrumentsDb();
% disp('save DB')
% save('./allInstrumentsDB.mat','Y','initnLambda');

load('../../../../data/Data_allinstrumentsNosat.mat');%get Y and initnLambda

%% Compute the dictionaries
initnLambda = 1;
dict.lambda_start = initnLambda;
k_dim_coeff = 1;%percentage of dim that we want for the atoms of the dictionary

[dicts] = learn_Dictionaries(Y,dict.lambda_start,k_dim_coeff);

save('./Dictionary.mat','dicts');

return;


for lambda2=dict.lambda_start:length(Y) 
    visualizing_dict(dicts.backward{l},lambda2);
end 

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






