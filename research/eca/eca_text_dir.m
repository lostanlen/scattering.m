function eca_text_dir(archs, folder, nLines)
%% List files
listing = list_dir(fullfile(folder, '*.wav'));
names = {listing.name};
nNames = length(names);
disp(['Found ', num2str(nNames), ' WAV files in directory ', folder]);
max_nDigits = 1 + floor(log10(nNames));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];

%% Retrieve parameters
Q1 = archs{1}.banks{1}.spec.nFilters_per_octave;
T = archs{1}.banks{1}.spec.T;
N = archs{1}.banks{1}.spec.size;
if length(archs) == 2
    modulations = 'none';
else
    switch length(archs{2}.banks)
        case 1
            modulations = 'time';
        case 2
            modulations = 'time-frequency';
        case 3
            modulations = 'spiral';
    end
end
wavelet_handle_str = func2str(archs{1}.banks{1}.spec.wavelet_handle);
switch wavelet_handle_str
    case 'morlet_1d'
        wavelet_str = 'mor';
    case 'gammatone_1d'
        wavelet_str = 'gam';
end

%% Generate arch_str
switch modulations
    case 'none'
        scattering_str = 'no';
    case 'time'
        scattering_str = 't';
    case 'time-frequency'
        scattering_str = 'tf';
    case 'spiral'
        scattering_str = 'sp';
end
arch_str = ...
    ['_Q=', num2str(Q1, '%0.2d'), ...
     '_J=', num2str(log2(T), '%0.2d'), ...
     '_sc=', scattering_str, ...
     '_wvlt=', wavelet_str];
folder_out = [folder, arch_str];
if ~exist(folder_out, 'dir')
    mkdir(folder_out);
end

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
    [y, sample_rate] = eca_load(audio_path);
    padding_length = ceil(length(y)/N) * N - length(y);
    y = cat(1, y, zeros(padding_length, 1));
    y_chunks = eca_split(y, N);
    S = sc_propagate(y_chunks, archs);
    text = eca_text({S}, nLines, sample_rate);
    text_name = [name(1:(end-4)), arch_str, '.txt'];
    text_path = fullfile(folder_out, text_name);
    file_id = fopen(text_path, 'w');
    fprintf(file_id, '%s', text); 
    fclose(file_id); 
end
end