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
% sub_Y = sc_upgrade(sub_Y,variable)

%% Multidimensional FFT
% TODO: avoid resorting to an anonymous handle
fft_handle = @(x) multidimensional_fft(x,variable.subscripts);
sub_Y.data_ft = map_unary(fft_handle,sub_Y.data);
end
