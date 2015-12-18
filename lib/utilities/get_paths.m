function file_list = get_paths(dir_name)
dir_data = dir(dir_name);
dir_index = [dir_data.isdir];
file_list = {dir_data(~dir_index).name}';
if ~isempty(file_list)
    file_list = ...
        cellfun(@(x) fullfile(dir_name,x), file_list,'UniformOutput',false);
end
sub_dirs = {dir_data(dir_index).name};
valid_index = ~ismember(sub_dirs,{'.','..'});
for dir_index = find(valid_index)
    next_dir = fullfile(dir_name,sub_dirs{dir_index});
    file_list = [file_list; get_paths(next_dir)];
end
end
