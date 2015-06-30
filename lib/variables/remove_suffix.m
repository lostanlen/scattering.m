function key_out = remove_suffix(key_in)
names = fieldnames(key_in);
name = names{1};
depth = length(key_in.(name));
tail = key_in.(name){depth};
if isempty(tail)
    key_out = [];
    return
end
tail_names = fieldnames(tail);
tail_name = tail_names{1};
tail_depth = length(key_in.(name));
tail_tail = tail.(tail_name){tail_depth};
if isempty(tail_tail)
    key_out.(name){depth} = [];
else
    tail_out = remove_suffix(tail);
    key_out.(name){depth} = tail_out;
end
end
