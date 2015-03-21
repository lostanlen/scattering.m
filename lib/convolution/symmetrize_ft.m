function symmetrized_ft = symmetrize_ft(tensor_ft,bank_behavior)
%%
subscripts = bank_behavior.subscripts;
colons = bank_behavior.colons;
tensor_sizes = size(tensor_ft);
signal_sizes = tensor_sizes(subscripts);
nSubscripts = length(subscripts);
switch nSubscripts
    case 1,
        flipped_range = signal_sizes(1):-1:(1+1);
        colons.subs{subscripts(1)} = flipped_range;
        flipped_ft = subsref(tensor_ft,colons);
        conj_flipped_ft = conj(flipped_ft);
        range = (1+1):signal_sizes(1);
        colons.subs{subscripts(1)} = range;
        nonzero_ft = subsref(tensor_ft,colons);
        halfsum_ft = (conj_flipped_ft + nonzero_ft) / 2;
        symmetrized_ft = ...
            subsasgn(tensor_ft,colons,halfsum_ft);
    case 2,
        error('Symmmetrization not ready in dimension 2');
    otherwise,
        error('Symmetrization not ready in dimension >2');
end
end
