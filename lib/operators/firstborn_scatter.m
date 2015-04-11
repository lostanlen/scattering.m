function [data,ranges] = firstborn_scatter(data_ft,bank,ranges)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    data = cell([input_sizes,1]);
    for node = 1:numel(data_ft)
        ranges_node = get_ranges_node(ranges,node);
        % Recursive call
        [data{node},ranges_node] = ...
            firstborn_scatter(data_ft{node},bank,ranges_node,sibling);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return;
elseif level_counter==0 && ~isnumeric(data_ft)
    nCousins = prod(input_sizes);
    data_ft = reshape(data_ft,[nCousins,1]);
else
    nCousins = 1;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
bank_spec = bank.spec;
nThetas = bank_spec.nThetas;
subscripts = bank_behavior.subscripts;
support_index = 1 + log2(bank.spec.size/get_signal_support(data_ft,subscripts));
try
  psis = bank.psis{support_index};
catch err
    disp(err);
end
is_deepest = level_counter<0;
is_numeric = isnumeric(data_ft);
is_oriented = nThetas>1;


%% Selection of filter indices ("gammas")
gamma_lower_bound = max(bank_behavior.gamma_bounds(1),1);
% Here we bound the gammas from above by the number of filters in the
% support-specific implementation
gamma_upper_bound = min(bank_behavior.gamma_bounds(2),length(psis));
gamma_range = [gamma_lower_bound,1,gamma_upper_bound].';
gammas = collect_range(gamma_range);
nEnabled_gammas = length(gammas);
if nEnabled_gammas<1
    data = [];
    return;
end

%% Definition of resampling factors
log2_oversampling = bank_behavior.U.log2_oversampling;
log2_resamplings = ...
    min(log2_oversampling + [bank.metas(gammas).log2_resolution].', 0);

%% Update of ranges at zeroth level (tensor level)
if is_deepest
    overhead_zeroth_ranges = ranges(1+0);
else
    overhead_zeroth_ranges = ranges{1+0};
end
if is_oriented
    theta_range = [1,1,bank_spec.nThetas].';
end
is_spiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'j');
if is_spiraled
    nChromas = bank_behavior.spiral.nChromas;
    octave_padding_length = bank_behavior.spiral.octave_padding_length;
    spiral_subscript = bank_behavior.spiral.subscript;
end
ranges{1+0} = cell(nCousins,nEnabled_gammas);
for cousin_index = 1:nCousins
    for gamma_index = 1:nEnabled_gammas
        local_zeroth_ranges = overhead_zeroth_ranges{cousin_index};
        log2_resampling = log2_resamplings(gamma_index);
        local_zeroth_ranges(2,subscripts) = pow2(-log2_resampling);
        if is_spiraled
            resliced_size = size(data_ft,spiral_subscript);
            nOctaves = pow2(nextpow2(octave_padding_length + ...
                resliced_size/nChromas));
            first_father = local_zeroth_ranges(1,spiral_subscript);
            local_zeroth_ranges(1,spiral_subscript) = ...
                1 + mod(first_father-1,nChromas);
            local_zeroth_ranges(3,spiral_subscript) = ...
                local_zeroth_ranges(1,spiral_subscript) + nChromas - 1;
            first_octave = 1 + floor(first_father/nChromas);
            octave_range = [first_octave;1;first_octave+nOctaves-1];
            local_zeroth_ranges = ...
                [local_zeroth_ranges(:,1:(spiral_subscript)), ...
                octave_range, ...
                local_zeroth_ranges(:,(spiral_subscript+1:end))];
        end
        if is_oriented
            local_zeroth_ranges = cat(2,local_zeroth_ranges,theta_range);
        end
        ranges{1+0}{cousin_index,gamma_index} = local_zeroth_ranges;
    end
end
if ~is_deepest && length(input_sizes)>1
    ranges{1+0} = reshape(ranges{1+0},[input_sizes,nEnabled_gammas]);
end

%% Update of ranges at first level (gamma level)
if is_deepest
    ranges{1+1} = zeros(3,0);
end
ranges{1+1} = cat(2,ranges{1+1},gamma_range);

%% Scattering implementations
%% DN. Deepest, Numeric
% e.g. time scattering of 1d signals
if is_deepest && is_numeric && ~is_oriented
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gammas(gamma_index));
        log2_resampling = log2_resamplings(gamma_index);
        data{gamma_index} = ifft_multiply(data_ft,psi, ...
            log2_resampling,colons,subscripts);
    end
end

%% N. Numeric
% e.g. time scattering of videos (after 2d scattering)
if ~is_deepest && is_numeric && ~is_oriented
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gammas(gamma_index));
        data_slice = cell(1,nCousins);
        log2_resampling = log2_resamplings(gamma_index);
        for cousin = 1:nCousins
            data_slice{cousin} = ifft_multiply(data_ft{cousin},psi, ...
                log2_resampling,colons,subscripts);
        end
        data(:,gamma_index) = data_slice;
    end
end

%% D&DO. Deepest and Deepest Oriented
% e.g. scattering along j in 1d
% e.g. scattering along gamma in 2d (after scattering in space)
if is_deepest && ~is_numeric
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gammas(gamma_index),:);
        log2_resampling = log2_resamplings(gamma_index);
        data{gamma_index} = map_filter(data_ft,psi, ...
            log2_resampling,bank.behavior);
    end
end

%% []&O. Shallow and Shallow Oriented
if ~is_deepest && ~is_numeric
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gammas(gamma_index),:);
        log2_resampling = log2_resamplings(gamma_index);
        data_slice = cell(nCousins,1);
        for cousin = 1:nCousins
            data_slice{cousin} = map_filter(data_ft{cousin},psi, ...
                log2_resampling,bank.behavior);
        end
        data(:,gamma_index) = data_slice;
    end
end


%% Definition of assignment structures for NO. and DNO.
if is_numeric && (is_oriented || is_spiraled)
    [output_sizes,subsasgn_structures,spiraled_sizes] = ...
        prepare_assignment(input_sizes,log2_resamplings,bank_behavior,nThetas);
end

%% DNO. Deepest, Numeric, Oriented
% e.g. scattering in 2d space
% e.g. scattering along gamma after blurring along time
if is_deepest && is_numeric && is_oriented
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        subsasgn_structure = subsasgn_structures{gamma_index};
        log2_resampling = log2_resamplings(gamma_index);
        y = zeros(output_sizes{gamma_index});
        for theta = 1:nThetas
            psi = psis(gammas(gamma_index),theta);
            subsasgn_structure.subs{end} = theta;
            y = subsasgn(y,subsasgn_structure, ...
                ifft_multiply(data_ft,psi, ...
                log2_resampling,colons,subscripts));
        end
        data{gamma_index} = y;
    end
end

%% NO. Numeric, Oriented
% e.g. first-order scattering along j (after scattering along gamma)
if ~is_deepest && is_numeric && is_oriented
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        data_slice = cell(1,nCousins);
        subsasgn_structure = subsasgn_structures{gamma_index};
        log2_resampling = log2_resamplings(gamma_index);
        gamma_output_sizes = output_sizes{gamma_index};
        for cousin = 1:nCousins
            y = zeros(gamma_output_sizes);
            for theta = 1:nThetas
                psi = psis(gammas(gamma_index),theta);
                subsasgn_structure.subs{end} = theta;
                y = subsasgn(y,subsasgn_structure, ...
                    ifft_multiply(data_ft,psi, ...
                    log2_resampling,colons,subscripts));
            end
            data_slice{cousin} = y;
        end
        data(:,gamma_index) = data_slice;
    end
end

%% Spiraling if required
if is_numeric && is_spiraled && ~strcmp(get_suffix(bank.behavior.key),'j')
    for cell_index = 1:numel(data)
        data{cell_index} = reshape(data{cell_index},spiraled_sizes{cell_index});
    end
end

%% Reshaping if required: [], N, O, NO.
if ~is_deepest && (length(input_sizes)>1)
    data = reshape(data,[input_sizes,nEnabled_gammas]);
end
