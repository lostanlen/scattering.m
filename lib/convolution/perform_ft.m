function sub_Y = perform_ft(sub_Y,key)
%% Cell-wise map
if iscell(sub_Y)
    % TODO: avoid resorting to anonymous handle
    perform_ft_handle = @(x) perform_ft(x,key);
    sub_Y = map_unary(perform_ft_handle,sub_Y);
    return
end
if isfield(sub_Y,'data_ft')
    return
end

%% Variable loading
branch = get_branch(sub_Y.variable_tree,key);
variable = branch.leaf;

%% Unpadding and upgrading
% This is needed e.g. for 3rd-order joint scattering along gamma and gamma2
% sub_Y = upgrade(sub_Y,variable)

%% Downgrading and padding
if variable.level>0
    subscripts = variable.subscripts;
    downgrading_handle = @(x) downgrade(x,subscripts);
    nLevels = length(sub_Y.keys) - 1;
    level_counter = nLevels - variable.level;
    sub_Y.data = map_hierarchic_handle(downgrading_handle, ...
        sub_Y.data,level_counter);
    nTensor_dimensions = length(sub_Y.keys{1});
    nSubscripts = length(subscripts);
    for subscript_index = 1:nSubscripts
        sub_Y.keys{1+variable.level}{subscripts(subscript_index)} = [];
        new_subscript = nTensor_dimensions + subscript_index;
        sub_Y.keys{1}{new_subscript} = key;
        variable.subscripts(subscript_index) = new_subscript;
    end
    variable.level = 0;
    variable.padding = parse_padding('zero');
    sub_Y.variable_tree = set_leaf(sub_Y.variable_tree,key,variable);
end

%% Multidimensional FFT
% TODO: avoid resorting to an anonymous handle
fft_handle = @(x) multidimensional_fft(x,variable.subscripts);
sub_Y.data_ft = map_unary(fft_handle,sub_Y.data);
end
