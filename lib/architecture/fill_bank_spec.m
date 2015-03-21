function spec = fill_bank_spec(opt)
%% Management of default parameters
spec.size = opt.size;
spec.T = default(opt,'T',min(spec.size));
spec.nFilters_per_octave = default(opt,'nFilters_per_octave',1);
spec.max_scale = default(opt,'max_scale',spec.T);
spec.max_Q = default(opt,'max_Q',spec.nFilters_per_octave);
spec.J = log2(spec.T);
signal_dimension = length(spec.size);
if signal_dimension==1
    nOrientations = 1;
elseif signal_dimension==2
    spec.nOrientations = default(opt,'nOrientations',8);
    nOrientations = spec.nOrientations;
end
spec.is_spinned = default(opt,'is_spinned',false);
nSpins = 1 + spec.is_spinned;
spec.nThetas = nSpins * nOrientations;
spec.has_duals = default(opt,'has_duals',false);
spec.has_mr_output = default(opt,'has_mr_output',true);
spec.has_multiple_support = default(opt,'has_multiple_support',false);
spec.periodization_extent = default(opt,'periodization_extent',1);
% TODO: implement single precision
spec.is_double_precision = default(opt,'is_double_precision',true);
if spec.is_double_precision
    epsilon = eps(double(1));
else
    epsilon = eps(single(1));
end
spec.trim_threshold = default(opt,'trim_threshold',epsilon);
spec.domain.is_ft = default(opt,'is_domain_ft',true);
spec.domain.is_ift = default(opt,'is_domain_ift',false);
if signal_dimension==1
    spec.handle = default(opt,'handle',@morlet_1d);
elseif signal_dimension==2
    error('2d wavelets not ready'); % TODO: write @morlet_2d
    spec.handle = @morlet_2d;
end

%% Management of handle-specific parameters
switch func2str(spec.handle)
    case 'gammatone_1d'
        spec.gammatone_order = default(opt,'gammatone_order',4);
        spec.cutoff_in_dB = default(opt,'cutoff_in_dB',3);
        spec.has_real_ft = false;
        spec.is_analytic = default(opt,'is_analytic',false);
        % We want the higher center log-frequency in the filter bank, log(mother_xi),
        % to be right in between its mirror log(1-mother_xi), and the second higher
        % frequency log(2^(-1/N)*mother_xi), where N is the number of filters per
        % octave.  Hence the required equality;
        % log(1-mother_xi) - log(mother_xi) =  log(2)/N
        % of which we easily derive the following formula.
        adjacency_ratio = 2^(1/spec.nFilters_per_octave);
        spec.mother_xi = default(opt,'mother_xi',1 / (1+adjacency_ratio));
    case 'morlet_1d'
        spec.has_real_ft = true;
    case 'poisson_1d'
        spec.decay_factor = default(opt,'decay_factor',0.2);
        spec.has_real_ft = false;
        spec.mother_xi = default(opt,'mother_xi',0.25);
end

if ~spec.has_real_ft
    spec.is_ift_flipped = default(opt,'is_ift_flipped',false);
end
%% Alphanumeric ordering of field names
spec = orderfields(spec);
end

