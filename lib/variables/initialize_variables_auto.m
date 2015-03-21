function U0 = initialize_variables_auto(tensor_sizes)
%% Size sorting and dimension inference
[sorted_sizes,sorting_indices] = sort(tensor_sizes,'descend');
if length(tensor_sizes)==2 && sorted_sizes(2)==1
    nDimensions = 1;
else
    nDimensions = length(tensor_sizes);
end

%% Signal variable inference 
variable_tree = struct();
keys{1+0} = cell(1,nDimensions);
signal_variable.level = 0;
% Typical images have aspect ratio of at most 4
if sorted_sizes(1)/sorted_sizes(2) < 4
    signal_subscripts = sorting_indices(1:2);
    signal_variable.subscripts = sorting_indices(1:2);
    signal_head_name = 'space';
    signal_dimension = 2;
else
    signal_subscripts = sorting_indices(1);
    signal_head_name = 'time';
    signal_dimension = 1;
end
signal_variable.original_sizes = tensor_sizes(signal_subscripts);
signal_variable.subscripts = signal_subscripts;
signal_key.(signal_head_name) = cell(1,1);
variable_tree = set_leaf(variable_tree,signal_key,signal_variable);
keys{1+0}{signal_variable.subscripts} = signal_key;

if nDimensions==(signal_dimension+1)
    %% Channel variable inference
    channel_variable.level = 0;
    channel_subscripts = sorting_indices(end);
    channel_variable.original_sizes = tensor_sizes(channel_subscripts);
    channel_variable.subscripts = channel_subscripts;
    channel_key.channel = cell(1,1);
    variable_tree = ...
        set_leaf(variable_tree,channel_key,channel_variable);
    keys{1+0}{channel_variable.subscripts} = channel_key;
elseif nDimensions~=signal_dimension
    %% Error throwing if signal is neither 1d nor 2d
    error('unable to infer variable names');
end

%% Output storage
U0.variable_tree = variable_tree;
U0.keys = keys;
end
