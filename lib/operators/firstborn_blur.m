function data = firstborn_blur(data_ft,bank,level_counter)
%% Deep map across levels
input_sizes = drop_trailing(size(data_ft),1);
if level_counter>0
    nCousins = numel(data_ft);
    data = cell(nCousins,1);
    for cousin = 1:nCousins
        data{cousin} = ...
            firstborn_blur(data_ft{cousin},bank,level_counter-1);
    end
    if length(input_sizes)>1
        data = reshape(data,input_sizes);
    end
    return;
elseif level_counter==0
    if ~isnumeric(data_ft)
        nCousins = prod(input_sizes);
    end
end

%% Loading
log2_resampling = bank.log2_resamplings;
phi = bank.phi;
colons = bank.behavior.colons;
subscripts = bank.behavior.subscripts;
is_deepest = level_counter<0;
is_numeric = isnumeric(data_ft);
is_spiraled = isfield(bank.behavior,'spiral') && ...
    ~strcmp(get_suffix(bank.behavior.key),'j');

%% Assignment preparation if spiraling is required
if is_spiraled
    spiral = bank.behavior.spiral;
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
if is_numeric && ~is_spiraled
    data = ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts);
end

if is_numeric && is_spiraled
    data = zeros(output_sizes);
    data = subsasgn(data,subsasgn_structure, ...
        ifft_multiply(data_ft,phi,log2_resampling,colons,subscripts));
end

if ~is_numeric && ~is_spiraled
    data = cell([input_sizes,1]);
    for cousin = 1:nCousins
        data{cousin} = map_filter(data_ft{cousin},phi, ...
            log2_resampling,bank.behavior);
    end
end

% TODO: implement ~is_numeric && is_spiraled
% need to write a specific map_filter for the blurring operator
% as well as a specific prepare_assignment (see conditional branch above)
%% Spiraling
if is_spiraled
    data = reshape(data,spiraled_sizes);
end

%% Reshaping
if ~is_deepest && ~is_numeric
    data = reshape(data,[input_sizes,1]);
end
end
