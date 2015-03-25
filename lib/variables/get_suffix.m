function [suffix_name,suffix_depth] = get_suffix(key_in)
names = fieldnames(key_in);
name = names{1};
depth = length(key_in.(name));
tail = key_in.(name){depth};
if isempty(tail)
    suffix_name = name;
    suffix_depth = depth;
else
    [suffix_name,suffix_depth] = get_suffix(tail);
end
end
