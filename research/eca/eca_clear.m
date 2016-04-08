function eca_clear(audio_path, Q1, T, modulations)
%% Make prefix
switch modulations
    case 'none'
        scattering_str = 'no';
    case 'time'
        scattering_str = 't';
    case 'time-frequency'
        scattering_str = 'tf';
end
arch_str = ...
    ['_Q=', num2str(Q1, '%0.2d'), ...
    '_J=', num2str(log2(T), '%0.2d'), ...
    '_sc=', scattering_str];
prefix = [audio_path(1:(end-4)), arch_str];

%% Match prefix of regular expression
regexp = [prefix, '_it*.wav'];
matches = dir(regexp);
names = {matches.name};
nNames = length(names);
folder = fileparts(audio_path);
prompt = ['Delete ', num2str(nNames), ...
    ' files matching ', fullfile(folder,regexp), ' ? (Y/N): '];
prompt_str = input(prompt, 's');
is_valid = false;
while ~(is_valid)
    switch prompt_str
        case 'n'
            return
        case 'N'
            return
        case 'no'
            return
        case 'y'
            break
        case 'Y'
            break
        case 'yes'
            break
    end
    prompt_str = input('Please type yes (Y) or no (N): ', 's');
end
is_valid = true;

%%
for name_index = 1:nNames
    name = names{name_index};
    path = fullfile(folder, name);
    delete(path);
end

disp('Deleted.');
end