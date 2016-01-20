function plans = setup_plans(opts)
%% Initialize cell array of plans
nLayers = length(opts);
plans = cell(1, nLayers);

%% First order
has_custom_invariants = ...
    isfield(opts{1}, 'banks') && isfield(opts{1}, 'invariants');
if has_custom_invariants
    if isfield(opts{1}.banks, 'time') && ~isfield(opts{1}.banks, 'space')
        root_name = 'time';
    elseif ~isfield(opts{1}.banks, 'time') && isfield(opts{1}.banks, 'space')
        root_name = 'space';
    end
else
    if isfield(opts{1}, 'time') && ~isfield(opts{1}, 'space')
        root_name = 'time';
    elseif ~isfield(opts{1},'time') && isfield(opts{1}, 'space')
        root_name = 'space';
    end
end
if has_custom_invariants
    root_bank_field = opts{1}.banks.(root_name);
    root_bank_field.key.(root_name) = cell(1);
    root_bank_field.name = root_name;
    root_bank_field.is_chunked = ...
        default(root_bank_field, 'is_chunked', false);
    signal_dimension = 1;
    root_bank_field.output_dimension = 1;
    root_bank_field.subscripts = 1;
    root_invariant_field = opts{1}.invariants.(root_name);
    root_invariant_field.key.(root_name) = cell(1);
    root_invariant_field.subscripts = 1;
    root_invariant_field.name = root_name;
    root_bank_field.is_U_blurred = ...
        default(root_bank_field, 'is_U_blurred', true);
    plans{1}.banks{1}.spec = fill_bank_spec(root_bank_field);
    plans{1}.banks{1}.behavior = fill_bank_behavior(root_bank_field);
    plans{1}.invariants{1}.spec = fill_invariant_spec(root_invariant_field);
    plans{1}.invariants{1}.behavior = ...
        fill_invariant_behavior(root_invariant_field);
else
    root_field = opts{1}.(root_name);
    root_field.name = root_name;
    root_field.is_chunked = ...
        default(root_field, 'is_chunked', true);
    root_field.is_U_blurred = ...
        default(root_field, 'is_U_blurred', false);
    if isfield(root_field, 'size') && ~isfield(root_field, 'T')
        root_field.T = root_field.size / 4;
    end
    root_field.T = drop_trailing(root_field.T);
    root_field.invariance = default(root_field, 'invariance', 'blurred');
    root_field.key.(root_name) = cell(1);
    signal_dimension = length(root_field.T);
    root_field.dimension = ...
        default(root_field,'dimension',signal_dimension);
    switch signal_dimension
        case 1
            if isfield(root_field,'is_spinned') && root_field.is_spinned
                root_field.output_dimension = root_field.dimension + 1;
            else
                root_field.output_dimension = root_field.dimension;
            end
        case 2
            root_field.output_dimension = root_field.dimension + 1;
    end
    root_field.subscripts = ...
        default(root_field,'subscripts',1:root_field.dimension);
    plans{1}.banks{1}.spec = fill_bank_spec(root_field);
    root_field.size = plans{1}.banks{1}.spec.size;
    plans{1}.banks{1}.behavior = fill_bank_behavior(root_field);
    plans{1}.invariants{1}.spec = ...
        fill_invariant_spec(root_field, plans{1}.banks{1}.spec);
    plans{1}.invariants{1}.behavior = ...
        fill_invariant_behavior(root_field, plans{1}.banks{1}.behavior);
end

%% Setup first-order nonlinearity
plans{1}.nonlinearity = fill_nonlinearity(opts{1});
ordered_names = {root_name, 'theta', 'gamma', 'j'};
nNames = length(ordered_names);

%% Upper orders
for layer = 2:nLayers
    plan = struct();
    opt = opts{layer};
    has_custom_invariants = isfield(opt, 'banks') || isfield(opt, 'invariants');
    if has_custom_invariants
        has_banks = isfield(opt, 'banks');
        if has_banks
            banks_opt = opt.banks;
        end
        has_invariants = isfield(opt, 'invariants');
        if has_invariants
            invariants_opt = opt.invariants;
        end
    else
        has_banks = ~isempty(opt);
        banks_opt = opt;
        invariants_opt = struct(root_name, opt.(root_name));
    end
    if has_custom_invariants && ~has_banks
        bank_names = {};
    else
        bank_names = fieldnames(banks_opt);
    end
    banks = {};
    for bank_name_index = 1:nNames
        opt_name = ordered_names{bank_name_index};
        items = strfind(bank_names, opt_name);
        if all(cellfun(@isempty, items))
            continue
        end
        field = banks_opt.(opt_name);
        field.name = opt_name;
        switch opt_name
            case root_name
                root_plan = plans{layer-1}.banks{1};
                previous_plan = plans{layer-1}.banks{end};
                field.T = default(field, 'T', root_plan.spec.T);
                field.size = enforce(field, 'size', root_plan.spec.size);
                field.dimension = previous_plan.behavior.output_dimension;
                field.is_U_blurred = false;
                field.wavelet_handle = default(field, 'wavelet_handle', ...
                    @gammatone_1d);
                field.output_dimension = ...
                    field.dimension + (layer==2) + (signal_dimension==2);
                field.subscripts = default(field, 'subscripts', ...
                    root_plan.behavior.subscripts);
                field.key.(root_name) = cell(1);
            case 'gamma'
                nChromas = plans{1}.banks{1}.spec.nFilters_per_octave;
                nGammas = plans{1}.banks{1}.spec.J * nChromas;
                % 1 octave of chroma filtering by default
                field.T = default(field, 'T', pow2(nextpow2(nChromas)));
                field.dimension = banks{end}.behavior.output_dimension + 1;
                field.invariance = default(field, 'invariance', 'bypassed');
                field.is_spinned = enforce(field, 'is_spinned', true);
                field.has_multiple_support = ...
                    enforce(field, 'has_multiple_support', true);
                field.key.(root_name){1}.gamma = cell(1);
                field.output_dimension = field.dimension + 1;
                field.size = enforce(field,'size', ...
                    pow2(nextpow2(nGammas + field.T)));
                field.subscripts = ...
                    default(field, 'subscripts', banks{1}.behavior.dimension + 1);
                banks{1}.behavior.gamma_padding_length = field.T / 2;
            case 'j'
                if isfield(field,'wavelet_handle')
                    wavelet_handle_str = func2str(field.wavelet_handle);
                    % It is better to have the impulsive part of the
                    % gammatone in the lower octaves
                    if strcmp(wavelet_handle_str, 'gammatone_1d') || ...
                            strcmp(wavelet_handle_str, 'RLC_1d')
                        field.is_ift_flipped = ...
                            default(field, 'is_ift_flipped', true);
                    end
                    % If wavelets are replaced by finite differences
                    if strcmp(wavelet_handle_str, 'finitediff_1d')
                        field.T = enforce(field, 'T', 2);
                        field.J = enforce(field, 'J', 2);
                        field.nFilters_per_octave = ...
                            enforce(field, 'nFilters_per_octave', 1);
                        field.max_Q = enforce(field, 'max_Q', 1);
                        field.nOctaves = enforce(field, 'nOctaves', 2);
                        field.is_spinned = enforce(field, 'is_spinned', false);
                    end
                end
                gamma_bounds = plans{1}.banks{1}.behavior.gamma_bounds;
                nGammas_bound = gamma_bounds(2) - gamma_bounds(1) + 1;
                nFilters_per_octave = ...
                    plans{1}.banks{1}.spec.nFilters_per_octave;
                nOctaves_bound = ceil(nGammas_bound / nFilters_per_octave);
                nOctaves = min(plans{1}.banks{1}.spec.J, nOctaves_bound);
                % 4 octaves of octave filtering by default
                field.T = default(field, 'T', 4);
                field.dimension = banks{end}.behavior.dimension+1;
                field.wavelet_handle = ...
                    default(field, 'wavelet_handle', @gammatone_1d);
                field.invariance = default(field, 'invariance', 'bypassed');
                field.is_spinned = default(field, 'is_spinned', true);
                field.has_multiple_support = ...
                    enforce(field, 'has_multiple_support', true);
                field.key.(root_name){1}.j = cell(1);
                field.output_dimension = field.dimension + 1;
                field.size = enforce(field,'size', ...
                    pow2(nextpow2(nOctaves + field.T)));
                field.subscripts = default(field, 'subscripts', ...
                    banks{1}.behavior.dimension + 2);
                if isfield(opt,'gamma')
                    % Here we assume that the transformation along gamma is
                    % in second position
                    spiral.nChromas = ...
                        plans{1}.banks{1}.spec.nFilters_per_octave;
                    spiral.octave_padding_length = field.T;
                    spiral.subscript = banks{1}.behavior.dimension + 1;
                    banks{2}.behavior.spiral = spiral;
                end
                field.spiral = spiral;
            case 'nonlinearity'
                continue
        end
        bank.behavior = fill_bank_behavior(field);
        bank.spec = fill_bank_spec(field);
        banks = cat(1, banks, bank);
    end
    if has_custom_invariants && ~has_invariants
        invariant_names = {};
    else
        invariant_names = fieldnames(invariants_opt);
    end
    invariants = {};
    for invariant_name_index = 1:nNames
        opt_name = ordered_names{invariant_name_index};
        if strcmp(opt_name, 'nonlinearity')
            continue
        end
        items = strfind(invariant_names, opt_name);
        if all(cellfun(@isempty, items))
            continue
        end
        field = invariants_opt.(opt_name);
        switch opt_name
            case 'time'
                field.key.time{1} = [];
            case 'gamma'
                field.key.time{1}.gamma{1} = [];
            case 'j'
                field.key.time{1}.j{1} = [];
        end
        if has_banks && isfield(banks_opt, opt_name)
            nBanks = length(banks);
            for bank_index = 1:nBanks
                bank = banks{bank_index};
                if strcmp(bank.behavior.name, opt_name)
                    break
                end
            end
            invariant.behavior = fill_invariant_behavior(field, bank.behavior);
            invariant.spec = fill_invariant_spec(field, bank.spec);
        else
            invariant.behavior = fill_invariant_behavior(field);
            invariant.spec = fill_invariant_spec(field);
        end
        invariants = cat(1, invariants, invariant);
    end
    if ~has_custom_invariants || has_banks
        plan.banks = banks;
    end
    if ~has_custom_invariants || has_invariants
        plan.invariants = invariants;
    end
    plan.nonlinearity = fill_nonlinearity(opt);
    plans{layer} = plan;
end
end
