function Y2s = get_Y2s(dataset_path, opts, lambda2_start)
%% Set lambda2_start to 4
if nargin<3
    lambda2_start = 4;
end
%% Get all waveforms
file_paths = get_paths(dataset_path);
nFiles = length(file_paths);
file_Y2s = cell(1,nFiles);

%% Compute architectures
archs = sc_setup(opts);

%% Compute second-order scattering
parfor file_index = 1:nFiles
    file_path = file_paths{file_index};
    waveform = audioread_compat(file_path);
    [~,~,Y] = sc_propagate(waveform, archs);
    Y2 = unchunk_layer(Y{2}{end});
    file_Y2s{file_index} = Y2.data(lambda2_start:end);
    disp(['Finished file ', file_path, ' on worker ', labindex(), ...
        ' at ', datestr(now, 'HH:MM:SS')])
end

%% Subsample
nLambda2s = length(file_Y2s{1});
parfor file_index = 1:nFiles
    for lambda2_index = 1:nLambda2s
        downsampling = 2^(nLambda2s-lambda_index);
        file_Y2s{file_index}{lambda2_index} = ...
            file_Y2s{file_index}{lambda2_index}(1:downsampling:end, :)
    end
end

%%
