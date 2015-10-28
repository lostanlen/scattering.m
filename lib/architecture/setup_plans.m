function plans = setup_plans(opts)
nLayers = length(opts);
plans = cell(1,nLayers);
if isfield(opts{1},'time') && ~isfield(opts{1},'space')
    root = 'time';
elseif ~isfield(opts{1},'time') && isfield(opts{1},'space')
    root = 'space';
end
%%
root_field = opts{1}.(root);
root_field.T = drop_trailing(root_field.T);
root_field.key.(root) = cell(1);
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
plans{1}.nonlinearity = fill_nonlinearity(opts{1});
ordered_names = {root,'theta','gamma','j'};

%%
for layer = 2:nLayers
    opt = opts{layer};
    banks = {};
    names = fieldnames(opt);
    nNames = length(ordered_names);
    for name_index = 1:nNames
        opt_name = ordered_names{name_index};
        items = strfind(names,opt_name);
        if all(cellfun(@isempty,items))
            continue;
        end
        field = opt.(opt_name);
        switch opt_name
            case root
                root_plan = plans{layer-1}.banks{1};
                previous_plan = plans{layer-1}.banks{end};
                field.T = default(field,'T',root_plan.spec.T);
                field.size = enforce(field,'size',root_plan.spec.size);
                field.dimension = previous_plan.behavior.output_dimension;
                field.is_U_blurred = false;
                field.handle = default(field,'handle',@gammatone_1d);
                field.output_dimension = ...
                    field.dimension + (layer==2) + (signal_dimension==2);
                field.subscripts = ...
                    default(field,'subscripts',root_plan.behavior.subscripts);
                field.key.(root) = cell(1);
            case 'gamma'
                nChromas = plans{1}.banks{1}.spec.nFilters_per_octave;
                nGammas = plans{1}.banks{1}.spec.J * nChromas;
                % 1 octave of chroma filtering by default
                field.T = default(field,'T',pow2(nextpow2(nChromas)));
                field.dimension = banks{end}.behavior.output_dimension + 1;
                field.invariance = default(field,'invariance','bypassed');
                field.is_spinned = enforce(field,'is_spinned',true);
                field.has_multiple_support = ...
                    enforce(field,'has_multiple_support',true);
                field.key.(root){1}.gamma = cell(1);
                field.output_dimension = field.dimension + 1;
                field.size = enforce(field,'size', ...
                    pow2(nextpow2(nGammas + field.T)));
                field.subscripts = ...
                    default(field,'subscripts',banks{1}.behavior.dimension + 1);
                banks{1}.behavior.gamma_padding_length = field.T / 2;
            case 'j'
                if isfield(field,'handle')
                    handle_str = func2str(field.handle);
                    % It is better to have the impulsive part of the
                    % gammatone in the lower octaves
                    if strcmp(handle_str, 'gammatone_1d') || ...
                            strcmp(handle_str,'RLC_1d') 
                        field.is_ift_flipped = ...
                            default(field, 'is_ift_flipped', true);
                    end
                    % If wavelets are replaced by finite differences
                    if strcmp(handle_str, 'finitediff_1d')
                        field.T = enforce(field, 'T', 2);
                        field.J = enforce(field, 'J', 2);
                        field.nFilters_per_octave = ...
                            enforce(field, 'nFilters_per_octave', 1);
                        field.max_Q = ...
                            enforce(field, 'max_Q', 1);
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
                field.handle = default(field,'handle',@gammatone_1d);
                field.invariance = default(field,'invariance','bypassed');
                field.is_spinned = default(field,'is_spinned',true);
                field.has_multiple_support = ...
                    enforce(field,'has_multiple_support',true);
                field.key.(root){1}.j = cell(1);
                field.output_dimension = field.dimension + 1;
                field.size = enforce(field,'size', ...
                    pow2(nextpow2(nOctaves + field.T)));
                field.subscripts = ...
                    default(field,'subscripts',banks{1}.behavior.dimension + 2);
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
        banks = cat(1,banks,bank);
    end
    plan.banks = banks;
    plan.nonlinearity = fill_nonlinearity(opt);
    plans{layer} = plan;
end
end
