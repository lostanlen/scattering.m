function [data,ranges] = firstborn_blur(data_ft,bank,ranges)
%% Deep map across levels
level_counter = length(ranges) - 1;
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    nNodes = numel(data_ft);
    data = cell([input_sizes,1]);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        [data{node},ranges_node] = ...
            firstborn_blur(data_ft{node},bank,ranges_node);
        ranges = set_ranges_node(ranges,ranges_node,node);
    end
    return;
end

%% Selection of signal-adapted support for the filter bank
bank_behavior = bank.behavior;
subscripts = bank_behavior.subscripts;
support_index = 1 + log2(bank.spec.size/get_signal_support(data_ft,subscripts));
phi = bank.phi{support_index};

%% Definition of resampling factor
critical_log2_sampling = 1 - log2(bank.spec.T);
log2_oversampling = bank_behavior.S.log2_oversampling;
log2_resampling = critical_log2_sampling + log2_oversampling;

%% Update of ranges at zeroth level (tensor level)
ranges{1+0}(2,subscripts) = pow2(-log2_resampling);

%% Initialization
colons = bank_behavior.colons;
is_spiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'j');

%% Assignment preparation if spiraling is required
if is_spiraled
    spiral = bank_behavior.spiral;
    nChromas = spiral.nChromas;
    output_sizes = input_sizes;
    resampled_sizes = pow2(output_sizes(subscripts),log2_resampling);
    output_sizes(subscripts) = resampled_sizes;
    resliced_sizes = output_sizes(spiral.subscript);
    resampled_nChromas = pow2(nChromas,log2_resampling);
    nOctaves = pow2(nextpow2(spiral.octave_padding_length + ...
        resliced_sizes/resampled_nChromas)-1);
    nPadded_gammas = resampled_nChromas * nOctaves;
    output_sizes(spiral.subscript) = nPadded_gammas;
    spiraled_sizes = ...
        [output_sizes(1:(spiral.subscript-1)), ...
        resampled_nChromas,nOctaves, ...
        output_sizes((spiral.subscript+1):end)];
    subsasgn_structure.type = '()';
    subsasgn_structure.subs = replicate_colon(1+length(input_sizes));
    subsasgn_structure.subs(subscripts) = ...
        arrayfun(@(x) 1:x,resampled_sizes,'UniformOutput',false);
    zeroth_ranges = ranges{1+0};
    first_father = zeroth_ranges(1,spiral.subscript);
    zeroth_ranges(1,spiral.subscript) = 1 + mod(first_father-1,nChromas);
    zeroth_ranges(3,spiral.subscript) = ...
        zeroth_ranges(1,spiral.subscript) + nChromas - 1;
    first_octave = 1 + floor(first_father/nChromas);
    octave_range = [first_octave;1;first_octave+nOctaves-1];
    zeroth_ranges = ...
        [zeroth_ranges(:,1:(spiral.subscript)), ...
        octave_range, ...
        zeroth_ranges(:,(spiral.subscript+1:end))];
    ranges(1+0) = {zeroth_ranges};
end

%% Blurring implementations
if ~is_spiraled
    data = ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts);
else
    data = zeros(output_sizes);
    data = subsasgn(data,subsasgn_structure, ...
        ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts));
end

%% Spiraling if required
if is_spiraled
    data = reshape(data,spiraled_sizes);
end
end
