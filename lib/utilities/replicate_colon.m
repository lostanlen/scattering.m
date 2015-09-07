function colons = replicate_colon(nColons)
switch nColons
    case 1
        colons = {':'};
    case 2
        colons = {':',':'};
    case 3
        colons = {':',':',':'};
    case 4
        colons = {':',':',':',':'};
    case 5
        colons = {':',':',':',':',':'};
    case 6
        colons = {':',':',':',':',':',':'};
    case 0
        colons = {};
    otherwise
        disp(nColons);
        warning('replicate_colon:TooManyColons', ...
            'replicate_colon calling repmat');
        colons = repmat({':'},1,nColons);
end
end
