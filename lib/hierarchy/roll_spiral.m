function sub_Y = roll_spiral(sub_Y,bank)
%% Get father key
key = bank.behavior.key;
father_key = remove_suffix(key);
[~,suffix_depth] = get_suffix(key);

%% Update gamma leaf as a chroma leaf
chroma_key = append_suffix(father_key,'gamma',suffix_depth);
chroma_leaf = get_leaf(sub_Y.variable_tree,chroma_key);
bank.behavior.spiral.chroma_log2_sampling = ...
    default(chroma_leaf,'log2_sampling',1);

%% Call recursive function roll_spiral_data
sub_Y.data_ft = roll_spiral_data(sub_Y.data_ft,bank);

%% Make octave leaf
spiraled_subscript = bank.behavior.spiral.subscript;
octave_leaf.level = 0;
octave_leaf.padding = parse_padding('zero');
octave_subscript = spiraled_subscript + 1;

%% Add octave leaf
[sub_Y.keys,sub_Y.variable_tree] = add_variable(sub_Y.keys, ...
    sub_Y.variable_tree,father_key,'j',octave_leaf,octave_subscript);
end
