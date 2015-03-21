function fullsupport_bank = ...
    build_fullsupport_bank(bank_fts,bank_ifts,bank)
signal_dimension = length(bank.behavior.subscripts);
if isempty(bank_fts)
    is_ft = false;
else
    is_ft = true;
    nGammas = size(bank_fts,signal_dimension+1);
    nThetas = size(bank_fts,signal_dimension+2);
end
if isempty(bank_ifts)
    is_ift = false;
    fullsupport_bank(1:nGammas,1:nThetas) = struct('ft',[],'ft_start',[]);
else
    is_ift = true;
    if ~is_ft
        nGammas = size(bank_ifts,signal_dimension+1);
        nThetas = size(bank_ifts,signal_dimension+2);
        fullsupport_bank(1:nGammas,1:nThetas) = ...
            struct('ift',[],'ift_start',[]);
    else
        fullsupport_bank(1:nGammas,1:nThetas) = ...
            struct('ft',[],'ft_start',[],'ift',[],'ift_start',[]);
    end
end
overhead_colons = substruct('()',replicate_colon(signal_dimension+2));
gamma_subscript = signal_dimension + 1;
theta_subscript = signal_dimension + 2;

%% Definition of subscript permutation
subscripts = bank.behavior.subscripts;
is_permuted = subscripts(end)>signal_dimension;
if is_permuted
    nSubscripts = length(subscripts);
    subscript_permutation = 1:max(subscripts);
    subscript_permutation(1:nSubscripts) = subscripts;
    subscript_permutation(subscripts) = 1:nSubscripts;
end

%% Trimming and permutation
for theta = 1:nThetas
    % This loop can be parallelized
    for gamma = 1:nGammas
        local_subsref_structure = overhead_colons;
        local_subsref_structure.subs{gamma_subscript} = gamma;
        local_subsref_structure.subs{theta_subscript} = theta;
        if is_ft
            slice_ft = subsref(bank_fts,local_subsref_structure);
            [trimmed_ft,ft_start] = trim_support(slice_ft,bank.spec);
            if is_permuted
                trimmed_ft = permute(trimmed_ft,subscript_permutation);
            end
        end
        if is_ift
            slice_ift = subsref(bank_ifts,local_subsref_structure);
            [trimmed_ift,ift_start] = trim_support(slice_ift,bank.spec);
            if is_permuted
                trimmed_ift = permute(trimmed_ift,subscript_permutation);
            end
        end
        if is_ft
            if is_ift
                fullsupport_bank(gamma,theta) = struct( ...
                    'ft',trimmed_ft,'ft_start',ft_start, ...
                    'ift',trimmed_ift,'ift_start',ift_start);
            else
                fullsupport_bank(gamma,theta) = struct( ...
                    'ft',trimmed_ft,'ft_start',ft_start);
            end
        else
            fullsupport_bank(gamma,theta) = struct( ...
                'ift',trimmed_ift,'ift_start',ift_start);
        end
    end
end
end
