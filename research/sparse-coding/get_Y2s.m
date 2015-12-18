function Y2s = get_Y2s(dataset_path, opts)
%% Get all waveforms
file_paths = get_paths(dataset_path);
nFiles = length(file_paths);
file_Y2s = cell(1,nFiles);

%% Compute architectures
archs = sc_setup(opts);

%%
parfor file_index = 1:nFiles
    file_path = file_paths{file_index};
    waveform = audioread_compat(file_path);
    [~,~,Y] = sc_propagate(waveform, archs);
    file_Y2s{file_index} = unchunk_layer(Y{2}{end});
    disp(['Finished file ', file_path, ' on worker ', labindex(), ...
        ' at ', datestr(now, 'HH:MM:SS')])
end

end

