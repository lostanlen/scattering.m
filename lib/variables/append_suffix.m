function key_out = append_suffix(key_in,suffix_name,suffix_depth)
if isempty(key_in)
    key_out.(suffix_name){suffix_depth} = [];
else
    names = fieldnames(key_in);
    name = names{1};
    depth = length(key_in.(name));
    tail = key_in.(name){depth};
    tail_out = append_suffix(tail,suffix_name,suffix_depth);
    key_out.(name){depth} = tail_out;
end
end
