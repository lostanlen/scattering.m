function [output_sizes,zeroth_ranges,subsasgn_structures,spiraled_sizes] = ...
    prepare_firstborn_scatter_spiral( ...
    input_size,enabled_log2_resamplings,subscripts,nThetas,ranges,spiral)
%% Initialization of outputs
nEnabled_gammas = length(enabled_log2_resamplings);
nChromas = spiral.nChromas;
octave_padding_length = spiral.octave_padding_length;
spiral_subscript = spiral.subscript;
is_deepest = ~iscell(input_size);
is_oriented = nThetas>1;
if is_deepest
    output_sizes = cell(nEnabled_gammas,1);
    zeroth_ranges = cell(nEnabled_gammas,1);
    subsasgn_structures = cell(nEnabled_gammas,1);
    spiraled_sizes = cell(nEnabled_gammas,1);
end
if length(subscripts)>1 || subscripts~=spiral_subscript
    % there is no straightforward use case for this
    error('spiraling only available when subscripts==spiral_subscript');
end

%% Loop over enabled gammas
if is_deepest && is_oriented
    % e.g. scattering along gamma while spiraling for next variable
    nSubscripts = length(input_size);
    overhead_subsasgn_structure = substruct('()',replicate_colon(1+nSubscripts));
    spiral_range = ranges{1+0}(:,spiral_subscript);
    unpadded_nOctaves = ceil((spiral_range(3)-spiral_range(1)) / nChromas);
    padded_nOctaves = pow2(nextpow2(unpadded_nOctaves + octave_padding_length));
    theta_range = [1;1;nThetas];
    local_size = cat(2,input_size,nThetas);
    local_range = cat(2,ranges{1+0}(:,1:spiral_subscript), ...
        [0;0;0],ranges{1+0}(:,(spiral_subscript+1):end),theta_range);
    first_father = ranges{1+0}(1,spiral_subscript);
    
    for gamma_index = 1:nEnabled_gammas
        % Definition of output sizes
        output_sizes{gamma_index} = local_size;
        log2_resampling = enabled_log2_resamplings(gamma_index);
        resampled_nChromas = pow2(nChromas,log2_resampling);
        nPadded_gammas = resampled_nChromas * padded_nOctaves;
        output_sizes{gamma_index}(spiral_subscript) = nPadded_gammas;
        
        % Definition of subsasgn structure
        subsasgn_structures{gamma_index} = overhead_subsasgn_structure;
        resampled_length = pow2(local_size(subscripts),log2_resampling);
        subsasgn_structures{gamma_index}.subs{subscripts} =  1:resampled_length;
        
        % Definition of spiraled size
        spiraled_sizes{gamma_index} = ...
            [output_sizes{gamma_index}(1:(spiral_subscript-1)), ...
            resampled_nChromas,padded_nOctaves, ...
            output_sizes{gamma_index}((spiral_subscript+1):end)];
        
        % Definition of ranges
        first_chroma = 1 + mod(first_father,resampled_nChromas);
        first_octave = 1 + floor(first_father/resampled_nChromas);
        octave_range = [first_octave;1;first_octave+unpadded_nOctaves-1];
        local_range(2,subscripts) = pow2(-log2_resampling);
        local_range(1,spiral_subscript) = first_chroma;
        local_range(:,spiral_subscript+1) = octave_range;
        zeroth_ranges{gamma_index} = local_range;
    end
end
end