function [output_sizes,subsasgn_structures,spiraled_sizes] = ...
    prepare_assignment(input_sizes,log2_resamplings, ...
    bank_behavior,nThetas)
%%
subscripts = bank_behavior.subscripts;
input_dimension = length(input_sizes);
overhead_subsasgn_structure.type = '()';
overhead_subsasgn_structure.subs = replicate_colon(1+input_dimension);
is_spiraling = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'j');
if is_spiraling
    spiral = bank_behavior.spiral;
end
nEnabled_gammas = length(log2_resamplings);
output_sizes = cell(1,nEnabled_gammas);
subsasgn_structures = cell(1,nEnabled_gammas);
spiraled_sizes = cell(1,nEnabled_gammas);
for gamma_index = 1:nEnabled_gammas
    log2_resampling = log2_resamplings(gamma_index);
    resampled_sizes = pow2(input_sizes(subscripts),log2_resampling);
    output_sizes{gamma_index} = [input_sizes,nThetas];
    output_sizes{gamma_index}(subscripts) = resampled_sizes;
    subsasgn_structures{gamma_index} = overhead_subsasgn_structure;
    subsasgn_structures{gamma_index}.subs(subscripts) = ...
        arrayfun(@(x) 1:x,resampled_sizes,'UniformOutput',false);
    if is_spiraling
        resliced_sizes = output_sizes{gamma_index}(spiral.subscript);
        nChromas = pow2(spiral.nChromas,log2_resampling);
        assert(~mod(nChromas,1));
        nOctaves = pow2(nextpow2(spiral.octave_padding_length + ...
            resliced_sizes/nChromas)-1);
        nPadded_gammas = nChromas * nOctaves;
        output_sizes{gamma_index}(spiral.subscript) = nPadded_gammas;
        subsasgn_structures{gamma_index}.subs{spiral.subscript} = ...
            1:resliced_sizes;
        spiraled_sizes{gamma_index} = ...
            [output_sizes{gamma_index}(1:(spiral.subscript-1)), ...
            nChromas,nOctaves, ...
            output_sizes{gamma_index}((spiral.subscript+1):end)];
    end
end
if ~is_spiraling
    spiraled_sizes = [];
end
end
