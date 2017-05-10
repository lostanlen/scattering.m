function eca_batch_dir(archs, folder, opts)
%% List files
listing = list_dir(fullfile(folder, '*.wav'));
names = {listing.name};
nNames = length(names);
disp(['Found ', num2str(nNames), ' WAV files in directory ', folder]);
max_nDigits = 1 + floor(log10(nNames));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];

%% Retrieve parameters
N = archs{1}.banks{1}.spec.size;

%% Re-synthesize all files found in folder
for name_index = 1:nNames
    name = names{name_index};
    header_str = [' **** FILE #', ...
        num2str(name_index, sprintf_format), ': ', ...
        name, ' **** '];
    nChars = length(header_str);
    disp(repmat('-', 1, nChars));
    disp(header_str);
    audio_path = fullfile(folder, name);
    [y, sample_rate, bit_depth] = eca_load(audio_path);
    opts.sample_rate = sample_rate;
    padding_length = ceil(length(y)/N) * N - length(y);
    y = cat(1, y, zeros(padding_length, 1));
    [sounds, texts] = eca_synthesize(y, archs, opts);
    eca_export(sounds, texts, folder, name, opts, ...
        sample_rate, bit_depth, archs);
end

end