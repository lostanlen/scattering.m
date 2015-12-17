%% Addpath for Sira
sira_path = ...
    '/Users/ferradans/Documents/Research/AudioSynth/code/toolbox_sparsity/';
addpath(genpath(sira_path));

%% Addpath for Vincent
vincent_path = '~/MATLAB/toolbox_sparsity';
addpath(genpath(vincent_path));

%% Setup options
% Order 1 along time
opts{1}.time.T = 2048;
opts{1}.time.max_scale = 4096; % about 93 ms
opts{1}.time.max_Q = 8;
 
% Nonlinearity between the two orders
opts{1}.nonlinearity.name = 'modulus';
 
% Order 2 in time
opts{2}.time.handle = @gammatone_1d;

%% Build filters
archs = sc_setup(opts);

%% Load waveform
oboe_path = 'research/sparse-coding/2366.wav';
[waveform, sample_rate] = audioread_compat(oboe_path);

%% Compute scattering
[S,U,Y] = sc_propagate(waveform, archs);

%% Unchunk Y2
Y2 = Y{1+2}{end}.data;
nLambda2s = length(Y2);
for lambda2_index = 1:nLambda2s
    sub_Y2 = Y2{lambda2_index};
    sizes = size(sub_Y2);
    sub_Y2 = reshape(sub_Y2, sizes(1)*sizes(2), sizes(3));
    Y2{lambda2_index} = permute(sub_Y2,[2 1]);
end
%% Compute the dictionaries
initnLambda = 4;
[dicts, error] = learn_Dictionaries(Y2, initnLambda);
alpha = sparse_forward(Y2, dicts, initnLambda);
Ybis = sparse_backward(alpha, dicts, initnLambda);


%check the overall error
flat = @(x)x(:);
errorComp = @(x)sum(x.^2,1);
for lambda2_index = initnLambda:nLambda2s
    
    aux = dicts{lambda2_index}*alpha{lambda2_index};
    errorConstr=mean(errorComp(aux - Y2{lambda2_index}));
    disp(['err on cosntr Y(' num2str(lambda2_index) ')=' num2str(errorConstr) ]);
    
    errorY=mean(errorComp(Ybis{lambda2_index} - Y2{lambda2_index}));
    disp(['err on Y(' num2str(lambda2_index) ')=' num2str(errorY) ]);
end 





