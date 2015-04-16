function bank_metas = fill_bank_metas(bank_spec)
%%
nGammas = bank_spec.nFilters_per_octave * bank_spec.J;
resolutions = 2.^(-(0:nGammas-1)/bank_spec.nFilters_per_octave);
handle_string = func2str(bank_spec.handle);

switch handle_string
    case 'morlet_1d'
        morlet_tradeoff = 4;
        unbounded_scales = morlet_tradeoff * bank_spec.max_Q./resolutions;
        scales = min(unbounded_scales,bank_spec.max_scale);
        quality_factors = max(scales.*resolutions / morlet_tradeoff,1);
        bandwidths = resolutions./quality_factors;
    case 'gammatone_1d'
        cutoff = 10^(-bank_spec.cutoff_in_dB/20);
        gammatone_order = bank_spec.gammatone_order;
        cutoff_root = nthroot(cutoff,gammatone_order);
        squared_cutoff_cathetus = 1 - cutoff_root*cutoff_root;
        cutoff_cathetus = sqrt(squared_cutoff_cathetus);
        alpha_multiplier = cutoff_root * gammatone_order * cutoff_cathetus;
        adjacency_ratio = 2^(1/bank_spec.nFilters_per_octave);
        mother_xi = 1 / (1+adjacency_ratio);
        lowerbound_alpha = 4 * mother_xi / bank_spec.max_scale;
        xis = mother_xi * resolutions;
        lowerbound_quality_multipliers = ...
            lowerbound_alpha ./ (alpha_multiplier*xis);
        lowerbound_alpha_qualities = ...
            sqrt((1+2*lowerbound_quality_multipliers.^2).^2-1);
        lowerbound_quality_powers = eps() + ...
            gammatone_order * cutoff_cathetus * lowerbound_alpha_qualities;
        bounded_quality_powers = min(lowerbound_quality_powers,0.5);
        bounded_quality_factors = - 1./ log2(1-bounded_quality_powers);
        [~,elbow_gamma] = find(bounded_quality_factors>1,1,'last');
        elbow_quality_factor = ...
            bounded_quality_factors(min(elbow_gamma+1,nGammas));
        if elbow_quality_factor<bank_spec.max_Q
            elbow_resolution = resolutions(elbow_gamma);
            elbow_bandwidth = elbow_resolution / elbow_quality_factor;
            bandwidths = repmat(resolutions(elbow_gamma),1,nGammas);
            mother_quality_factor = ...
                min(bank_spec.max_Q,bounded_quality_factors(1));
            mother_bandwidth = 1 / mother_quality_factor;
            bandwidth_extrema = [mother_bandwidth,elbow_bandwidth];
            resolution_extrema = [resolutions(1),elbow_resolution];
            bandwidths(1:elbow_gamma) = interp1(resolution_extrema, ...
                bandwidth_extrema,resolutions(1:elbow_gamma));
            quality_factors = max(resolutions ./ bandwidths,1);
        else
            quality_factors = repmat(bank_spec.max_Q,1,nGammas);
            bandwidths = max(resolutions ./ bank_spec.max_Q,1);
        end
        scales = 4 * mother_xi ./ bandwidths;
    case 'RLC_1d'
        % TODO : review these parameters
        assert(bank_spec.max_Q==1);
        quality_factors = ones(size(resolutions));
        scales = [2 4];
        %scales = log(2) ./ (bank_spec.decay_factor * resolutions);
        bandwidths = 1 ./ scales;
end
%%
log2_resolutions = min(0,1+floor(log2(resolutions)));
bank_metas(1:nGammas,1) = struct( ...
    'bandwidth',num2cell(bandwidths), ...
    'gamma', num2cell(1:nGammas), ...
    'log2_resolution',num2cell(log2_resolutions), ...
    'quality_factor',num2cell(quality_factors), ...
    'resolution',num2cell(resolutions), ...
    'scale',num2cell(scales));
end

