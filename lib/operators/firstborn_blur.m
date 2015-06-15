function [data,ranges] = firstborn_blur(data_ft,bank,ranges)
%% Deep map across levels
level_counter = length(ranges) - 1;
input_size = drop_trailing(size(data_ft),1);
if level_counter>0
    nNodes = numel(data_ft);
    data = cell([input_size,1]);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            firstborn_blur(data_ft{node},bank,ranges_node);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data_ft,ranges,subscripts);
support_index = 1 + log2(bank.spec.size/signal_support);
phi = bank.phi{support_index};

%% Definition of resampling factor
critical_log2_sampling = 1 - log2(bank.spec.T);
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_resampling = min(critical_log2_sampling + log2_oversampling, 0);

%% Assignment preparation and update of ranges
is_spiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'j');
if is_spiraled
    spiral = bank_behavior.spiral;
    nChromas = spiral.nChromas;
    octave_padding_length = spiral.octave_padding_length;
    spiral_subscript = spiral.subscript;
    if length(subscripts)>1 || subscripts~=spiral_subscript
        % there is no straightforward use case for this
        error('spiraling only avaiable when subscripts==spiral_subscript');
    end

    % Definition of number of octaves
    nSubscripts = length(input_size);
    spiral_range = ranges{1+0}(:,spiral_subscript);
    unpadded_nOctaves = ceil((spiral_range(3)-spiral_range(1)+1) / nChromas);
    padded_nOctaves = pow2(nextpow2(unpadded_nOctaves + octave_padding_length));

    % Definition of output_size
    resampled_nChromas = pow2(nChromas,log2_resampling);
    nPadded_gammas = resampled_nChromas * padded_nOctaves;
    output_size = input_size;
    output_size(subscripts) = nPadded_gammas;

    % Definition of subsasgn_structure
    resampled_length = pow2(input_size(subscripts),log2_resampling);
    subsasgn_structure = substruct('()',replicate_colon(1+nSubscripts));
    subsasgn_structure.subs{spiral_subscript} = 1:resampled_length;

    % Definition of spiraled size
    spiraled_size = ...
        cat(2, output_size(1:(spiral_subscript-1)), ...
        resampled_nChromas, padded_nOctaves, ...
        output_size((spiral_subscript+1):end));

    % Definition of range
    first_father = ranges{1+0}(1,spiral_subscript);
    first_chroma = 1 + mod(first_father,resampled_nChromas);
    last_chroma = first_chroma + nChromas;
    first_octave = 1 + floor(first_father/resampled_nChromas);
    spiral_range = [first_chroma;pow2(-log2_resampling);last_chroma];
    octave_range = [first_octave;1;first_octave+unpadded_nOctaves-1];
    ranges{1+0} = cat(2, ranges{1+0}(:,1:(spiral_subscript-1)), ...
        spiral_range, octave_range, ...
        ranges{1+0}(:,(spiral_subscript+1):end));
else
    ranges{1+0}(2,subscripts) = pow2(-log2_resampling);
end

%% Blurring implementations
%% []. Normal
if ~is_spiraled
    data = ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts);
else
    %% S. Spiraled
    data = subsasgn(zeros(output_size),subsasgn_structure, ...
        ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts));
    data = reshape(data,spiraled_size);
end
end
