function [Y,initnLambda]=generate_allInstrumentsDb(dataset_path)

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
opts{2}.time.gamma_bounds = [initnLambda Inf];
opts{2}.time.max_Q = 1;

%% Build filters
archs = sc_setup(opts);

%% Load database in order to compute the dictionaries
disp('Load paths')
%dataset_path = '~/data/medleydb-single-instruments/';
training_paths = get_medleydb_paths(dataset_path, 'training');

stem_paths = [training_paths{:}];
chunk_paths = [stem_paths{:}];

%% initialize dataset 
disp('initialize DB')
[stereo_waveform, sample_rate] = audioread_compat(chunk_paths{1});
if size(stereo_waveform,2) > 1
    mono_waveform = mean(stereo_waveform, 2);
else 
    mono_waveform = stereo_waveform;
end
if size(mono_waveform,1) < N
    mono_waveform=cat(1,mono_waveform,zeros(N-size(mono_waveform,1),1));
end 


[~,~,Yaux] = sc_propagate(mono_waveform(1:N,1), archs);

nLambda2s = length(Yaux{2}{end}.data);
Y = cell(1, nLambda2s);
parfor lambda2_index = 1:nLambda2s
    nLambda1s = size(Yaux{2}{end}.data{lambda2_index}, 2);
    Y{lambda2_index} = complex(zeros(nLambda1s,length(chunk_paths)));  
end 

%% Compute scattering and save in DB
disp('generate DB')
for n = 1:length(chunk_paths)
    %disp(['waveform: ' chunk_paths{n}]);
    disp(['waveform: ' num2str(n) '/' num2str(length(chunk_paths))]);
    [stereo_waveform, ~] = audioread_compat(chunk_paths{n});
    if size(stereo_waveform,2) > 1
        mono_waveform = mean(stereo_waveform, 2);
    else 
        mono_waveform = stereo_waveform;
    end 
    if size(mono_waveform,1) < N
        mono_waveform=cat(1,mono_waveform,zeros(N-size(mono_waveform,1),1));
    end
    %% Compute scattering
    [~,~,Y_sample] = sc_propagate(mono_waveform(1:N,1), archs);
    Y2 = Y_sample{2}{end};
    nLambda2s = length(Y2.data);
    for lambda2_index = 1:nLambda2s
        Y{lambda2_index}(:,n) = Y2.data{lambda2_index}(end/2,:);
    end 
end 

