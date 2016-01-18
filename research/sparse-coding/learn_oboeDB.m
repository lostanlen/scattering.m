%Data learning: 

sira_path = ...
    '/Users/ferradans/Documents/Research/AudioSynth/code/toolbox_sparsity/';
addpath(genpath(sira_path));

data='/Users/ferradans/Documents/Research/AudioSynth/data/oboe_Y2s/';

files = dir([data '*.mat']);
for j=1:7
    Data{j}=[];
end 

%we are leaving the last 3 for testing
for i=1:length(files)-3
    
    aux = load([data files(i).name]);
    for j=1:length(aux.file_Y2)
        Data{j} = cat(1,Data{j},aux.file_Y2{j});
        
    end 
    
end 


%% Compute the dictionaries
initnLambda = 1;

%Y.data=Y2{7};
%% Select the subset for the training and set data sizes
j=1;
N = 25000;
l1=size(Data{1},2);
I=1:N;%randperm(size(Data{1},1));
for j=1:size(Data,2)
    subsetData{j} = permute(Data{j}(I(1:N),:),[2 1]);
end 

dict.lambda_start = initnLambda;

[dicts, error] = learn_Dictionaries(subsetData,dict.lambda_start,1/1.5);
dicts.lambda_start = initnLambda;

Y.data = subsetData;

alphas = sparse_forward(Y, dicts); %Y-D*alphas
Ytilde = sparse_backward(alphas, dicts);


%% Now test on the test set
for lambda2_index = initnLambda:length(Y.data)
    Ytest.data{lambda2_index} = permute(Data{lambda2_index}(I(N+1:end),:),[2 1]);
end 

alphas_test = sparse_forward(Ytest, dicts); %Y-D*alphas
Ytilde_test = sparse_backward(alphas_test, dicts);



%%

% check the overall error
disp('Check the error in the approximation of the DB:')
nLambda2s = length(Y.data);
flat = @(x)x(:);
errorComp = @(x)sum(x.^2,1);
disp(['For training set: y-D alpha    y-y_tilde ']);
for lambda2_index = initnLambda:nLambda2s
    
    aux = dicts.backward{lambda2_index}*alphas.data{lambda2_index};
    errorConstr=norm(mean(errorComp(aux - Y.data{lambda2_index})));
    errorY=norm(mean(errorComp(Ytilde.data{lambda2_index} - Y.data{lambda2_index})));
    
    disp(['(' num2str(lambda2_index) ') ' num2str(errorConstr) '   ' num2str(errorY)]); 
end  

disp(['For test set: y-D alpha    y-y_tilde ']);
for lambda2_index = initnLambda:nLambda2s 
    
    aux = dicts.backward{lambda2_index}*alphas_test.data{lambda2_index};
    errorConstr=norm(mean(errorComp(aux - Ytest.data{lambda2_index})));
    errorY=norm(mean(errorComp(Ytilde_test.data{lambda2_index} - Ytest.data{lambda2_index})));
    disp(['(' num2str(lambda2_index) ') ' num2str(errorConstr) '   ' num2str(errorY)]);
   
end



%% Show Y and DX for 7th lambda2
lambda2 = 7;

range = 1:4900;
subplot(211);
imagesc(Y2{lambda2}(:,range));
subplot(212);
imagesc(dicts{lambda2}*alphas{lambda2}(:,range))