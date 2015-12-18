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

%% Save
for file_index = 1:nFiles
    file_Y2 = file_Y2s{file_index};
    save(['Y2s_', num2str(file_index, '%0.2d')], 'file_Y2')
end
