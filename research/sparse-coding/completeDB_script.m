
disp('Generating data from all instruments')
pathLibri = '~/data/LibriSpeech/';
[Y,initnLambda]=generate_allInstrumentsDb(pathLibri);
disp('save DB')
save('../../../../data/allLibri.mat','Y','initnLambda');

%save('../../../../data/allInstrumentsDB_3secs.mat','Y','initnLambda');
%% Compute the dictionaries

k_dim_coeff = 1;%percentage of dim that we want for the atoms of the dictionary
disp(['Learn the dictionaries:'])
dicts = learn_Dictionaries(Y,1,k_dim_coeff);
save('../../../../data/Dictionary_Libri.mat',dicts);

return
% save('../../../../data/Dictionarylambda_normdata_3secs_good.mat','dicts');
% disp('.. and saving dictionaries ')

load('../../../../data/Dictionarylambda_normdata_3secs_good.mat')

% k_dim_coeff = 0.8;%percentage of dim that we want for the atoms of the dictionary
% 
% [dicts] = learn_Dictionaries(Y,dict.lambda_start,k_dim_coeff);
% save('./Dictionarynolambdanosquared.mat','dicts');
Q=16;
for lambda2=7:length(dicts.backward)
    d = register_peaks(dicts.backward{lambda2},Q);
    visualizing_Ordered_dict(d,Q);
   %  visualizing_dict(d);
  %  save(h,['./dicts_' num2str(lambda2) '.png']);
end 

return;

%% process a single audio file 
disp('initialize DB')
path='../../../../data/clarinet_Beethoven_S08_chunk000.wav';
[stereo_waveform, sample_rate] = audioread_compat(path);
clarinet = mean(stereo_waveform, 2);

path='../../../../data/piano_SwingJazz_S03_chunk000.wav';
[stereo_waveform, sample_rate] = audioread_compat(path);
piano = mean(stereo_waveform, 2);

% Setup options
N = 131072;
T = N;
initnLambda = 7;
opts{1}.time.T = T;
opts{1}.time.size = N;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.is_chunked = false;
opts{1}.time.has_duals = true;
opts{1}.time.gamma_bounds = [1 128];

opts{2}.time.T = T;
opts{2}.time.max_scale = Inf;
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.sibling_mask_factor = 2;
opts{2}.time.gamma_bounds = [initnLambda Inf]
opts{2}.time.max_Q = 1;
%example get for the last lambda2
lambda2=length(dicts.backward);
D = dicts.backward{lambda2};

params.modeD=0; %atoms with norm 1
params.mode=1; %l1 norm on the coefs alpha
params.iter = 3000;
%params.batchsize=512;
params.numThreads=-1; % number of threads
params.verbose=true;

% Build filters
archs = sc_setup(opts);

% process clarinet
[~,~,Y_sample] = sc_propagate(clarinet, archs);
Y2 = Y_sample{2}{end};
nLambda2s = length(Y2.data);
for lambda2_index = 1:nLambda2s
    Y_clarinet{lambda2_index}(:,1) = Y2.data{lambda2_index}(end/2,:);
end 

%show dictionary ordered by importance for lambda2 **real**
params.lambda=10;%super sparse
alpha_clarinet=mexLasso(real(Y_clarinet{lambda2}),real(D),params);
[abspeaks,abslocs] = findpeaks(abs(alpha_clarinet),'MinPeakHeight',0.2,'MinPeakDistance',3); 
figure;subplot(121);imagesc(D(:,abslocs))
subplot(122);plot(alpha_clarinet);hold on;plot(abslocs,alpha_clarinet(abslocs),'*r')

% process piano
[~,~,Y_sample] = sc_propagate(piano, archs);
Y2 = Y_sample{2}{end};
nLambda2s = length(Y2.data);
for lambda2_index = 1:nLambda2s
    Y_piano{lambda2_index}(:,1) = Y2.data{lambda2_index}(end/2,:);
end 

%show dictionary ordered by importance for lambda2 **real**
params.lambda=10;%super sparse
alpha_piano=mexLasso(real(Y_piano{lambda2}),real(D),params);
[abspeaks,abslocs] = findpeaks(abs(alpha_piano),'MinPeakHeight',0.2,'MinPeakDistance',3); 
figure;subplot(121);imagesc(D(:,abslocs))
subplot(122);plot(alpha_piano);hold on;plot(abslocs,alpha_piano(abslocs),'*r')
%%


%Checking how sparse the representation is
%take last lambda2


lambda2=4;%length(dicts.backward);
D = dicts.backward{lambda2};

%show dictionary ordered by importance for lambda2 **real**
alpha_real=mexLasso(real(Y{lambda2}),real(D),params);
[~,peak_lambda1s] = sort(sum(abs(alpha_real)>0.1,2),1,'descend');
h=visualizing_dict(dicts.backward,lambda2);
subplot(122);imagesc(real(D(:,peak_lambda1s)));title('real ordered by importance')

%show dictionary ordered by importance for lambda2 **complex**
alpha_imag=mexLasso(imag(Y{lambda2}),imag(D),params);
[~,peak_lambda1s] = sort(sum(abs(alpha_real)>0.1,2),1,'descend');
h=visualizing_dict(dicts.backward,lambda2);
subplot(121);imagesc(imag(D(:,peak_lambda1s)));title('imag ordered by importance')
    

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






