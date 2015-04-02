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
signal_range = ranges{1+0}(:,subscripts);
signal_log2_support = nextpow2(min(signal_range(end,:)-signal_range(1,:))+1);
support_index = log2(bank.spec.size) - signal_log2_support + 1;
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
    % TODO: update ranges in this conditional statement
    spiral = bank_behavior.spiral;
    output_sizes = input_sizes;
    resampled_sizes = ...
        pow2(output_sizes(subscripts),log2_resampling);
    output_sizes(subscripts) = resampled_sizes;
    resliced_sizes = output_sizes(spiral.subscript);
    nChromas = pow2(spiral.nChromas,log2_resampling);
    assert(~mod(nChromas,1));
    nOctaves = pow2(nextpow2(spiral.octave_padding_length + ...
        resliced_sizes/nChromas)-1);
    nPadded_gammas = nChromas * nOctaves;
    output_sizes(spiral.subscript) = nPadded_gammas;
    spiraled_sizes = ...
        [output_sizes(1:(spiral.subscript-1)), ...
        nChromas,nOctaves, ...
        output_sizes((spiral.subscript+1):end)];
    subsasgn_structure.type = '()';
    subsasgn_structure.subs = replicate_colon(1+length(input_sizes));
    subsasgn_structure.subs(subscripts) = ...
        arrayfun(@(x) 1:x,resampled_sizes,'UniformOutput',false);
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
