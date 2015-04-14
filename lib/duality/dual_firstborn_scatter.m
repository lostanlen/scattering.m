function data_ft = ...
    dual_firstborn_scatter(data,bank,ranges,data_ft_out,ranges_out)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_size = drop_trailing(size(data_ft),1);
if level_counter>0
    error('level_counter>0 in dual_firstborn_scatter not ready');
else
end
end