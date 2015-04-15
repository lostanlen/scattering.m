function sub_Y = perform_ift(sub_Y,subscripts)
%% Cell-wise map
if iscell(sub_Y)
    perform_ft_handle = @(x) perform_ift(x,subscripts);
    sub_Y = map_unary(perform_ft_handle,sub_Y);
    return
end

%% Multidimensional IFFT
% TODO: avoid resorting to an anonymous handle
ifft_handle = @(x) multidimensional_ifft(x,subscripts);
sub_Y.data = map_unary(ifft_handle,sub_Y.data_ft);
end