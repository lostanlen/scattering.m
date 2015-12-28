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

alphas = sparse_forward(Y, dicts);
Ytilde = sparse_backward(alphas, dicts);





%%

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
lambda2 = 7;

range = 1:4900;
subplot(211);
imagesc(Y2{lambda2}(:,range));
subplot(212);
imagesc(dicts{lambda2}*alphas{lambda2}(:,range))