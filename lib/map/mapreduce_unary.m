function y = mapreduce_unary(map_handle,x)
y = 0;
if iscell(x)
    if iscell(x{1})
        for cell_index = 1:numel(x)
            mapped_x = mapreduce_unary(map_handle,x{cell_index});
            y = y + sum(mapped_x(:));
        end
    else
        for cell_index = 1:numel(x)
            mapped_x = map_handle(x{cell_index});
            y = y + sum(mapped_x(:));
        end
    end
else
    mapped_x = map_handle(x);
    y = y + sum(mapped_x(:));
end
end