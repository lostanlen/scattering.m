function dimension = get_handle_dimension(handle)
handle_string = func2str(handle);
dimension = str2double(handle_string(end-1));
dimension = floor(dimension);
end

