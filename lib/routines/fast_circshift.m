function array = fast_circshift(array,shift_sizes,colons)
shift_sizes = mod(shift_sizes,size(array));
if all(shift_sizes==0)
    return;
end
nShifting_subscripts = sum(shift_sizes~=0);
if nShifting_subscripts>1
    array = circshift(array,shift_sizes);
else
    %% TODO: implement sparse matrix multiplication in the case of
    % small arrays (N<512)
    shifting_subscript = find(shift_sizes~=0,1);
    array_length = size(array,shifting_subscript);
    shift_length = shift_sizes(shifting_subscript);
    cut = array_length-shift_length;
    first_range = (cut+1):array_length;
    colons.subs{shifting_subscript} = first_range;
    first_chunk = subsref(array,colons);
    second_range = 1:cut;
    colons.subs{shifting_subscript} = second_range;
    second_chunk = subsref(array,colons);
    array = cat(shifting_subscript,first_chunk,second_chunk);
end
end