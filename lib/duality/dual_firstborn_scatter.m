function data_out = ...
    dual_firstborn_scatter(data_in,bank,ranges,data_ft_out,ranges_out)
%% Deep map across levels
level_counter = length(ranges) - 2;
input_size = size(data_in);
if level_counter>0
    nNodes = prod(input_size);
    data_out = cell(input_size);
    for node = 1:nNodes
        % Recursive call
        ranges_node = get_ranges_node(ranges,node);
        ranges_out_node = get_ranges_node(ranges_out,node);
        data_out{node} = dual_firstborn_scatter(data_in{node}, ...
            bank,ranges_node,data_ft_out{node},ranges_out_node);
    end
    if length(input_size)>1
        data_out = reshape(data_out,input_size);
    end
    return
end

%% Selection of signal-adapted support to the filter bank
bank_behavior = bank.behavior;
colons = bank_behavior.colons;
subscripts = bank_behavior.subscripts;
signal_support = get_signal_support(data_in,ranges,subscripts);
support_index = log2(bank.spec.size/signal_support) + 1;
dual_psis = bank.dual_psis{support_index};

%% Dual-scattering implementations
gamma_range = ranges{end}(:,bank_behavior.gamma_subscript);
gammas = collect_range(gamma_range);
nGammas = length(gammas);
nThetas = size(dual_psis,2);
is_oriented = nThetas>1;
is_deepest = size(ranges{end},2)==1;

%% Definition of resampling factors
enabled_log2_samplings = [bank.metas(gammas).log2_resolution].';
log2_oversampling = bank_behavior.U.log2_oversampling;
enabled_log2_resamplings = - min(enabled_log2_samplings + log2_oversampling, 0);

%% Dual-blurring implementations
is_unspiraled = isfield(bank_behavior,'spiral') && ...
    ~strcmp(get_suffix(bank_behavior.key),'gamma');
%% D. Deepest
% e.g. along time
if is_deepest && ~is_oriented
    for gamma_index = 1:nGammas
        gamma = gammas(gamma_index);
        log2_resampling = enabled_log2_resamplings(gamma_index);
        data_ft_out = multiply_fft_inplace(data_in{gamma_index},dual_psis(gamma), ...
            log2_resampling,colons,subscripts,data_ft_out);
    end
    data_out = multidimensional_ifft(data_ft_out,subscripts);
    return
end

%% DO. Deepest, Oriented
% e.g. along gamma variable
if is_deepest && is_oriented && ~is_unspiraled
    % In-place multiply-add in Fourier domain
    for gamma_index = 1:nGammas
        gamma = gammas(gamma_index);
        log2_resampling = enabled_log2_resamplings(gamma_index);
        for theta = 1:nThetas
            dual_psi = dual_psis(gamma,theta);
            colons.subs{end} = theta;
            data_ft_out = multiply_fft_inplace(data_in{gamma_index},dual_psi, ...
                log2_resampling,colons,subscripts,data_ft_out);
        end
    end
    % Inverse Fourier transform
    data_out = multidimensional_ifft(data_ft_out,subscripts);
    
    % Upadding
    output_dimension = ndims(data_out);
    nUnpadded_gammas = ...
        ranges_out{1+0}(3,subscripts) - ranges_out{1+0}(1,subscripts) + 1;
    subsref_structure = substruct('()',replicate_colon(output_dimension));
    subsref_structure.subs{subscripts} = 1:nUnpadded_gammas;
    data_out = subsref(data_out,subsref_structure);
    return
end

%% OS. Oriented, unSpiraled
% e.g. along j variable
if is_oriented && is_unspiraled
    spiral = bank_behavior.spiral;
    spiral_subscript = spiral.subscript;
    nCousins = input_size(1);
    data_out = cell(nCousins,1);
    for cousin = 1:nCousins
        % Loading
        x_ft = data_ft_out{cousin};
        
        % In-place multiply-add in Fourier domain
        for gamma_index = 1:nGammas
            log2_resampling = enabled_log2_resamplings(gamma_index);
            for theta = 1:nThetas
                dual_psi = dual_psis(gammas(gamma_index),theta);
                colons.subs{end} = theta;
                x_ft = multiply_fft_inplace( ...
                    data_in{cousin,gamma_index},dual_psi, ...
                    log2_resampling,colons,subscripts,x_ft);
            end
        end
        
        % Inverse Fourier transform
        x = multidimensional_ifft(x_ft,subscripts);
        
        % Unspiraling
        output_size = size(x);
        unspiraled_size = [ ...
            output_size(1:(spiral_subscript-1)), ...
            output_size(spiral_subscript)*output_size(spiral_subscript+1), ...
            output_size((spiral_subscript+2):end)];
        x = reshape(x,unspiraled_size);
        
        % Unpadding
        nPadded_gammas = size(x,spiral_subscript);
        nUnpadded_gammas = pow2(floor(nextpow2(nPadded_gammas)));
        if nUnpadded_gammas<nPadded_gammas
            nSubscripts = length(output_size) - 1;
            subsref_structure = substruct('()',replicate_colon(nSubscripts));
            subsref_structure.subs{spiral_subscript} = 1:nUnpadded_gammas;
            x = subsref(x,subsref_structure);
        end
        
        % Assignment
        data_out{cousin} = x;
    end
    return
end
