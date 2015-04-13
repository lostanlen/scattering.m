function [output_sizes,zeroth_ranges] = prepare_firstborn_scatter_nospiral( ...
    input_size,enabled_log2_resamplings,subscripts,nThetas,ranges)
%% Initialization of outputs
nEnabled_gammas = length(enabled_log2_resamplings);
is_deepest = ~iscell(input_size);
is_oriented = nThetas>1;
if is_deepest
    output_sizes = cell(nEnabled_gammas,1);
    zeroth_ranges = cell(nEnabled_gammas,1);
else
    cousin_size = drop_trailing(size(input_size,1));
    nCousins = prod(cousin_size);
    output_sizes = cell(nCousins,nEnabled_gammas);
    zeroth_ranges = cell(nCousins,nEnabled_gammas);
end

%% Loop over enabled gammas
if is_deepest && is_oriented
    % e.g. 2d scattering
    theta_range = [1;1;nThetas];
    local_size = cat(2,input_size,nThetas);
    local_range = cat(2,ranges{1+0},theta_range);
    for gamma_index = 1:nEnabled_gammas
        log2_resampling = enabled_log2_resamplings(gamma_index);
        local_size(subscripts) = pow2(input_size(subscripts,log2_resampling));
        output_sizes{gamma_index} = local_size;
        zeroth_ranges{gamma_index} = local_range;
        zeroth_ranges{gamma_index}(2,subscripts) = ...
            pow2(local_range(2,subscripts),-log2_resampling);
    end
    return
elseif is_deepest && ~is_oriented
    % e.g. 1d scattering
    output_sizes = []; % pre-allocation is not needed in this case
    for gamma_index = 1:nEnabled_gammas
        log2_resampling = enabled_log2_resamplings(gamma_index);
        zeroth_ranges{gamma_index} = ranges{1+0};
        zeroth_ranges{gamma_index}(2,subscripts) = ...
            pow2(ranges{1+0}(2,subscripts),-log2_resampling);
    end
    return
elseif ~is_deepest && is_oriented
    % e.g. scattering along gamma in joint time-frequency scattering
    % e.g. scattering along j in spiral scattering
    % e.g. scattering along theta in roto-translation scattering
    theta_range = [1;1;nThetas];
    for cousin = 1:nCousins
        local_range = cat(2,ranges{1+0}{cousin},theta_range);
        local_size = cat(2,input_size{cousin},nThetas);
        for gamma_index = 1:nEnabled_gammas
            log2_resampling = enabled_log2_resamplings(gamma_index);
            output_sizes{cousin,gamma_index} = local_size;
            output_sizes{cousin,gamma_index}(subscripts) = ...
                pow2(local_size(subscripts),log2_resampling);
            zeroth_ranges{cousin,gamma_index} = local_range;
            zeroth_ranges{cousin,gamma_index}(2,subscripts) = ...
                pow2(local_range(2,subscripts),-log2_resampling);
        end
    end
end

%% Transpose or reshape outputs if needed
if ~is_deepest && length(cousin_size)>1
    output_sizes = reshape(output_sizes,[cousin_size,nEnabled_gammas]);
    zeroth_ranges = reshape(zeroth_ranges,[cousin_size,nEnabled_gammas]);
end
end