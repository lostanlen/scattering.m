%%% Addpath for Sira
%sira_path = ...
%    '/Users/ferradans/Documents/Research/AudioSynth/code/toolbox_sparsity/';
sira_path='~/code/scattering.m/';
addpath(genpath(sira_path));

%% Addpath for Vincent
vincent_path = '~/MATLAB/toolbox_sparsity';
addpath(genpath(vincent_path));

%% Setup options
N = 131072;
T = N / 4;
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
opts{2}.time.max_Q = 1;

nLambda2s = log2(T);

%% Build filters
archs = sc_setup(opts);

%% Load database in order to compute the dictionaries
disp('Load paths')
dataset_path = '~/data/medleydb-single-instruments/'
training_paths = get_medleydb_paths(dataset_path, 'training');

stem_paths = [training_paths{:}];
chunk_paths = [stem_paths{:}];

%% initialize dataset 
disp('initialize DB')
[waveform, sample_rate] = audioread_compat(chunk_paths{1});

initnLambda = 7;
[~,~,Yaux] = sc_propagate(waveform, archs);
Y1 = unchunk_layer(Yaux{1}{end});
nLambda1s = length(Y1.data);

parfor lambda2_index = initnLambda:nLambda2s
    Y{lambda2_index} = zeros(nLambda1s,length(chunk_paths));  
end 

%% Compute scattering and save in DB
disp('generate DB')
for n=1:length(chunk_paths)
    disp(['waveform:' num2str(n)]);
    [waveform, sample_rate] = audioread_compat(chunk_paths{n});

    %% Compute scattering
    [~,~,Yaux] = sc_propagate(waveform, archs);

    %%Unchunk Y2
    Y2 = unchunk_layer(Yaux{2}{end});
    nLambda2s = length(Y2.data);
    for lambda2_index = initnLambda:nLambda2s
        Y{lambda2_index}(:,n) = Y2.data(end/2,:);
    end 
end 
disp('save DB')
save('../data/allInstrumentsDB.mat','Y','initnLambda');