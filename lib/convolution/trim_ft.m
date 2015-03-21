function trimmed_ft = trim_ft(tensor_ft,trimmed_sizes,shift,bank_spec)
%% Measurement of signal sizes
subscripts = bank_spec.subscripts;
nSubscripts = length(subscripts);
tensor_sizes = size(tensor_ft);
signal_sizes = tensor_sizes(subscripts);

%% Range selection of coefficients in filter
if nSubscripts>1
    error('multidimensional shifting not ready yet'); % TODO
end
trimmed_range = 1:trimmed_sizes(1);
if shift~=0
    shifted_range = bsxfun(@plus,shift,trimmed_range);
    mod_ranges = bsxfun(@mod,shifted_range-1,signal_sizes.') + 1;
else
    mod_ranges = trimmed_range;
end

%% Trimming
subsref_structure = bank_spec.subsref_structure;
subsref_structure.subs{subscripts} = mod_ranges;
trimmed_ft = subsref(tensor_ft,subsref_structure);
end
