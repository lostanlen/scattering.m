function paths = get_medleydb_paths(dataset_path, subfolder)
%%
set_path = fullfile(dataset_path, subfolder);

%%
instrument_dirs = list_dir(set_path);
instrument_names = {instrument_dirs.name};
nInstruments = length(instrument_names);
paths = cell(1, nInstruments);

for instrument_index = 0:(nInstruments-1)
    instrument_name = instrument_names{1+instrument_index};
    instrument_path = [set_path, '/', instrument_name];
    stem_dirs = list_dir(instrument_path);
    stem_names = {stem_dirs.name};
    nStems = length(stem_names);
    paths{1+instrument_index} = cell(1, nStems);
    for stem_index = 0:(nStems-1)
        stem_name = stem_names{1+stem_index};
        stem_path = [instrument_path, '/', stem_name];
        chunk_dirs = list_dir(stem_path);
        chunk_names = {chunk_dirs.name};
        paths{1+instrument_index}{1+stem_index} = ...
            cellfun(@(name) [stem_path, '/', name], chunk_names, ...
            'UniformOutput', false);
    end
end
end