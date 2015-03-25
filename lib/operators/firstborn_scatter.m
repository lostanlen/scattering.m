function data = firstborn_scatter(data_ft,bank,level_counter)
%% Deep dispatch across levels
input_sizes = drop_trailing(size(data_ft));
if level_counter>0
    nCousins = numel(data_ft);
    data = cell(nCousins,1);
    for cousin = 1:nCousins
        data{cousin} = ...
            firstborn_scatter(data_ft{cousin},bank,level_counter-1);
    end
    if length(input_sizes)>1
        data = reshape(data,input_sizes);
    end
    return;
elseif level_counter==0
    if ~isnumeric(data_ft)
        nCousins = prod(input_sizes);
        data_ft = reshape(data_ft,[nCousins,1]);
    end
end

%% Data structure initialization
log2_resamplings = bank.log2_resamplings;
nEnabled_gammas = length(log2_resamplings);
psis = bank.psis;
colons = bank.behavior.colons;
subscripts = bank.behavior.subscripts;
bank_spec = bank.spec;
nThetas = bank_spec.nThetas;
is_deepest = level_counter<0;
is_numeric = isnumeric(data_ft);
is_oriented = nThetas>1;

%% Scattering implementations
%% DN. Deepest, Numeric
% e.g. time scattering of 1d signals
if is_deepest && is_numeric && ~is_oriented
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gamma_index);
        log2_resampling = log2_resamplings(gamma_index);
        data{gamma_index} = ifft_multiply(data_ft,psi, ...
            log2_resampling,colons,subscripts);
    end
end

%% N. Numeric
% e.g. time scattering of videos (after 2d scattering)
if ~is_deepest && is_numeric && ~is_oriented
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gamma_index);
        data_slice = cell(1,nCousins);
        log2_resampling = log2_resamplings(gamma_index);
        for cousin = 1:nCousins
            data_slice{cousin} = ifft_multiply(data_ft{cousin},psi, ...
                log2_resampling,colons,subscripts);
        end
        data(:,gamma_index) = data_slice;
    end
end


%% D&DO. Deepest and Deepest Oriented
% e.g. scattering along j in 1d
% e.g. scattering along gamma in 2d (after scattering in space)
if is_deepest && ~is_numeric
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gamma_index,:);
        log2_resampling = log2_resamplings(gamma_index);
        data{gamma_index} = map_filter(data_ft,psi, ...
            log2_resampling,bank.behavior);
    end
end

%% []&O. Shallow and Shallow Oriented
if ~is_deepest && ~is_numeric
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        psi = psis(gamma_index,:);
        log2_resampling = log2_resamplings(gamma_index);
        data_slice = cell(nCousins,1);
        for cousin = 1:nCousins
            data_slice{cousin} = map_filter(data_ft{cousin},psi, ...
                log2_resampling,bank.behavior);
        end
        data(:,gamma_index) = data_slice;
    end
end


%% Definition of assignment structures for NO. and DNO.
is_spiraled = isfield(bank.behavior,'spiral');
if is_numeric && (is_oriented || is_spiraled)
    [output_sizes,subsasgn_structures,spiraled_sizes] = ...
        prepare_assignment(input_sizes,log2_resamplings,bank.behavior,nThetas);
end

%% DNO. Deepest, Numeric, Oriented
% e.g. scattering in 2d space
% e.g. scattering along gamma after blurring along time
if is_deepest && is_numeric && is_oriented
    data = cell(nEnabled_gammas,1);
    for gamma_index = 1:nEnabled_gammas
        subsasgn_structure = subsasgn_structures{gamma_index};
        log2_resampling = log2_resamplings(gamma_index);
        y = zeros(output_sizes{gamma_index});
        for theta = 1:nThetas
            psi = psis(gamma_index,theta);
            subsasgn_structure.subs{end} = theta;
            y = subsasgn(y,subsasgn_structure, ...
                ifft_multiply(data_ft,psi, ...
                log2_resampling,colons,subscripts));
        end
        data{gamma_index} = y;
    end
end

%% NO. Numeric, Oriented
% e.g. first-order scattering along j (after scattering along gamma)
if ~is_deepest && is_numeric && is_oriented
    data = cell(nCousins,nEnabled_gammas);
    for gamma_index = 1:nEnabled_gammas
        data_slice = cell(1,nCousins);
        subsasgn_structure = subsasgn_structures{gamma_index};
        log2_resampling = log2_resamplings(gamma_index);
        gamma_output_sizes = output_sizes{gamma_index};
        for cousin = 1:nCousins
            y = zeros(gamma_output_sizes);
            for theta = 1:nThetas
                psi = psis(gamma_index,theta);
                subsasgn_structure.subs{end} = theta;
                y = subsasgn(y,subsasgn_structure, ...
                    ifft_multiply(data_ft,psi, ...
                    log2_resampling,colons,subscripts));
            end
            data_slice{cousin} = y;
        end
        data(:,gamma_index) = data_slice;
    end
end

%% Spiraling if required
if is_numeric && is_spiraled && ~strcmp(get_suffix(bank.behavior.key),'j')
    for cell_index = 1:numel(data)
        data{cell_index} = reshape(data{cell_index},spiraled_sizes{cell_index});
    end
end

%% Reshaping if required: [], N, O, NO.
if ~is_deepest && (length(input_sizes)>1)
    data = reshape(data,[input_sizes,nEnabled_gammas]);
end
