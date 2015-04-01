function index_array = collect_range(range)
switch length(range)
    case 2
        index_array = range(1):range(2);
    case 3
        index_array = range(1):range(2):range(3);
end
end