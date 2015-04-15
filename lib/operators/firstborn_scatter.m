function [data,ranges] = firstborn_scatter(data_ft,bank,ranges)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_size = drop_trailing(size(data_ft),1);
if level_counter>0
    data = cell([input_size,1]);
    for node = 1:numel(data_ft)
        ranges_node = get_ranges_node(ranges,node);
        % Recursive call
        [data{node},ranges_node] = ...
            firstborn_scatter(data_ft{node},bank,ranges_node);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return
elseif level_counter==0
    is_deepest = false;
    nCousins = prod(input_size);
    data_size = cellfun(@size,data_ft,'UniformOutput',false);
    input_dimension = length(drop_trailing(data_size{1}));
    data_ft = reshape(data_ft,[nCousins,1]);
else
    is_deepest = true;
    data_size = input_size;
    input_dimension = length(drop_trailing(data_size));
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
bank_spec = bank.spec;
nThetas = bank_spec.nThetas;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data_ft,ranges,subscripts);
support_index = 1 + log2(bank.spec.size/signal_support);
psis = bank.psis{support_index};
is_oriented = nThetas>1;
is_spiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank.behavior.key),'j');

%% Selection of filter indices ("gammas")
gamma_lower_bound = max(bank_behavior.gamma_bounds(1),1);
gamma_upper_bound = min(bank_behavior.gamma_bounds(2),length(psis));
gamma_range = [gamma_lower_bound,1,gamma_upper_bound].';
gammas = collect_range(gamma_range);
nEnabled_gammas = length(gammas);

%% Definition of resampling factors
enabled_log2_samplings = [bank.metas(gammas).log2_resolution].';
log2_oversampling = bank_behavior.U.log2_oversampling;
enabled_log2_resamplings = min(enabled_log2_samplings + log2_oversampling, 0);

%% Assignment preparation and update of ranges
if is_spiraled
    spiral = bank_behavior.spiral;
    [output_sizes,ranges{1+0},subsasgn_structures,spiraled_sizes] = ...
        prepare_firstborn_scatter_spiral( ...
        data_size,enabled_log2_resamplings,subscripts,nThetas,ranges,spiral);
else
    [output_sizes,ranges{1+0}] = prepare_firstborn_scatter_nospiral( ...
        data_size,enabled_log2_resamplings,subscripts,nThetas,ranges);
end
if is_deepest
    ranges{1+1} = gamma_range;
else
    ranges{1+1} = cat(2,ranges{1+1},gamma_range);
end

%% Scattering implementations
%% D. Deepest
% e.g. time scattering of 1d signals
if is_deepest && ~is_oriented && ~is_spiraled
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gammas(gamma_index));
        log2_resampling = enabled_log2_resamplings(gamma_index);
        data{gamma_index} = ifft_multiply(data_ft,psi, ...
            log2_resampling,colons,subscripts);
    end
    return
end

%% DO. Deepest, Oriented
% e.g. scattering along space for images
% e.g. scattering along gamma in joint time-frequency scattering
% e.g. scattering along j after blurring (or bypassing) gamma
if is_deepest && is_oriented && ~is_spiraled
    data = cell(nEnabled_gammas,1);
    subsasgn_structure = substruct('()',replicate_colon(input_dimension+1));
    for gamma_index = 1:nEnabled_gammas
        log2_resampling = enabled_log2_resamplings(gamma_index);
        y = zeros(output_sizes{gamma_index});
        for theta = 1:nThetas
            psi = psis(gammas(gamma_index),theta);
            subsasgn_structure.subs{end} = theta;
            y = subsasgn(y,subsasgn_structure, ...
                ifft_multiply(data_ft,psi,log2_resampling,colons,subscripts));
        end
        data{gamma_index} = y;
    end
    return
end

%% DOS. Deepest, Oriented, Spiraled
% e.g. scattering along gamma in spiral
if is_deepest && is_oriented
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        subsasgn_structure = subsasgn_structures{gamma_index};
        log2_resampling = enabled_log2_resamplings(gamma_index);
        y = zeros(output_sizes{gamma_index});
        for theta = 1:nThetas
            psi = psis(gammas(gamma_index),theta);
            subsasgn_structure.subs{end} = theta;
            y = subsasgn(y,subsasgn_structure, ...
                ifft_multiply(data_ft,psi, ...
                log2_resampling,colons,subscripts));
        end
        data{gamma_index} = reshape(y,spiraled_sizes{gamma_index});
    end
    return
end

%% O. Oriented
% e.g. scattering along j in after scattering along gamma
% e.g. scattering along theta in roto-translation scattering
if ~is_deepest && is_oriented && ~is_spiraled
    data = cell(nCousins,nEnabled_gammas);
    subsasgn_structure = substruct('()',replicate_colon(input_dimension+1));
    for cousin = 1:nCousins
        x_ft = data_ft{cousin};
        for gamma_index = 1:nEnabled_gammas
            log2_resampling = enabled_log2_resamplings(gamma_index);
            output_size = output_sizes{cousin,gamma_index};
            data{cousin,gamma_index} = zeros(output_size);
            for theta = 1:nThetas
                psi = psis(gammas(gamma_index),theta);
                subsasgn_structure.subs{end} = theta;
                data{cousin,gamma_index} = ...
                    subsasgn(data{cousin,gamma_index},subsasgn_structure, ...
                    ifft_multiply(x_ft,psi,log2_resampling,colons,subscripts));
            end
        end
    end
    if length(input_size)>1
        data = reshape(data,[input_size,nEnabled_gammas]);
    end
    return
end
