function sub_Y = make_spiral(sub_Y,bank)
%%
key = bank.behavior.key;
father_key = remove_suffix(key);
[~,suffix_depth] = get_suffix(key);
chroma_key = append_suffix(father_key,'gamma',suffix_depth);
chroma_leaf = get_leaf(sub_Y.variable_tree,chroma_key);
bank.behavior.spiral.chroma_log2_sampling = ...
    default(chroma_leaf,'log2_sampling',1);
sub_Y.data_ft = reshape_spiral(sub_Y.data_ft,bank);
spiraled_subscript = bank.behavior.spiral.subscript;
octave_leaf.level = 0;
octave_leaf.padding = parse_padding('zero');
octave_subscript = spiraled_subscript + 1;
[sub_Y.keys,sub_Y.variable_tree] = add_variable(sub_Y.keys, ...
    sub_Y.variable_tree,father_key,'j',octave_leaf,octave_subscript);
end