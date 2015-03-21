function flipped_ft = flip_ft(tensor_ft,bank_spec)
%%
subscripts = bank_spec.subscripts;
subsref_structure = bank_spec.subsref_structure;
tensor_sizes = size(tensor_ft);
signal_sizes = tensor_sizes(subscripts);
nDimensions = ndims(tensor_ft) - isvector(tensor_ft);
if length(subsref_structure.subs)<nDimensions
    nMissing_dimensions = nDimensions - length(subsref_structure.subs);
    missing_cells = repmat({':'},1,nMissing_dimensions);
    subsref_structure.subs(end:nDimensions) = missing_cells;
end
%%
nSubscripts = length(subscripts);
switch nSubscripts
    case 1,
        flipped_range = [1,signal_sizes(1):-1:(1+1)];
        subsref_structure.subs{subscripts(1)} = flipped_range;
        flipped_ft = subsref(tensor_ft,subsref_structure);
    case 2,
        error('Symmmetrization not ready in dimension 2')
    otherwise,
        error('Symmetrization not ready in dimension >2')
end
end
