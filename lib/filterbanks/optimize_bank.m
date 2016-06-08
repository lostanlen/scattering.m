function optimized_banks = optimize_bank(bank_fts, bank_ifts, bank)
fullsupport_bank = build_fullsupport_bank(bank_fts, bank_ifts, bank);
if ~bank.spec.has_multiple_support
    optimized_banks{1} = fullsupport_bank;
    return;
end
subscripts = bank.behavior.subscripts;
signal_dimension = length(bank.spec.size);
if isempty(bank_fts)
    is_ft = false;
else
    is_ft = true;
    is_bank = (sum(size(bank_fts)~=1)>signal_dimension);
    if is_bank
        nThetas = size(bank_fts, signal_dimension+2);
    end
end
if isempty(bank_ifts)
    is_ift = false;
    initial_struct = struct( ...
        'ft_pos', [], 'ft_posfirst', [], 'ft_neg', [], 'ft_neglast', []);
else
    is_ift = true;
    if ~is_ft
        is_bank = (sum(size(bank_fts)~=1)>signal_dimension);
        if is_bank
            nThetas = size(bank_fts,signal_dimension+2);
        end
        initial_struct = struct('ift', [], 'ift_start', []);
    else
        initial_struct = ...
            struct('ft_pos', [], 'ft_posfirst', [], ...
            'ft_neg', [], 'ft_neglast', [], ...
            'ift', [], 'ift_start', []);
    end
end
if isfield(bank, 'metas')
    scales = cat(signal_dimension + 1, bank.metas.scale);
else
    scales = bank.spec.T;
end
log2_min_scale = floor(log2(min(scales, [], signal_dimension+1)));
log2_ratios = log2(bank.spec.size) - log2_min_scale;
nSupports = 1 + min(log2_ratios);
optimized_banks = cat(2, {fullsupport_bank}, cell(1,nSupports-1));
if is_ft
    nTensor_dimensions = ...
        length(drop_trailing(size(fullsupport_bank(1).ft_pos)));
else
    nTensor_dimensions = ...
        length(drop_trailing(size(fullsupport_bank(1).ift)));
end
overhead_colons.type = '()';
overhead_colons.subs = replicate_colon(nTensor_dimensions);

%%
for support_index = 2:nSupports
    bigger_bank = optimized_banks{support_index-1};
    if nTensor_dimensions<length(bank.spec.size)
        return
    end
    downsampling = pow2(support_index-1);
    support = bank.spec.size / downsampling;
    if is_bank
        smaller_nGammas = find(scales<=support, 1, 'last');
        if isempty(smaller_nGammas)
            continue
        end
        smaller_nLambdas = smaller_nGammas * nThetas;
    else
        smaller_nLambdas = 1;
    end
    smaller_bank = repmat(initial_struct, 1, smaller_nLambdas);
    % This loop can be parallelized
    for lambda = 1:smaller_nLambdas
        pos_subsref_structure = overhead_colons;
        neg_subsref_structure = overhead_colons;
        bigger_filter = bigger_bank(lambda);
        pos_bigger_sizes = size(bigger_filter.ft_pos);
        neg_bigger_sizes = size(bigger_filter.ft_neg);
        for subscript = 1:length(pos_bigger_sizes)
            pos_subsref_structure.subs{subscript} = ...
                1:2:pos_bigger_sizes(subscript);
        end
        for subscript = 1:length(neg_bigger_sizes)
            neg_subsref_structure.subs{subscript} = ...
                1:2:neg_bigger_sizes(subscript);
        end
        if is_ft
            smaller_filter.ft_pos = ...
                subsref(bigger_filter.ft_pos, pos_subsref_structure);
            smaller_filter.ft_posfirst = ...
                ceil(bigger_filter.ft_posfirst/2);
            smaller_filter.ft_neg = ...
                subsref(bigger_filter.ft_neg, neg_subsref_structure);
            smaller_filter.ft_neglast = ...
                floor(bigger_filter.ft_neglast/2);
        end
        if is_ift
            smaller_filter.ift = periodize(bigger_filter.ift, subscripts);
            smaller_filter.ift_start = 1 + floor(bigger_filter.ift_start/2);
        end
        smaller_bank(lambda) = smaller_filter;
    end
    if is_bank
        optimized_banks{support_index} = ...
            reshape(smaller_bank,smaller_nGammas, nThetas);
    else
        optimized_banks{support_index} = smaller_bank;
    end
end
end
