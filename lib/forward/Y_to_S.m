function layer_S = Y_to_S(layer_Y, arch)
%% Count banks
if isfield(arch, 'banks')
    banks = arch.banks;
    nBanks = length(banks);
else
    nBanks = 0;
end

%% Count invariants
invariants = arch.invariants;
nInvariants = length(invariants);

%% Two initialisation shortcuts
% This boolean is true at the last layer
is_U_bypassed = (length(layer_Y)==1);
% This boolean is true at the first layer (except for videos)
is_U_single_scattered = nBanks==1 && ...
    banks{1}.behavior.U.is_scattered && ...
    ~banks{1}.behavior.U.is_blurred && ...
    ~banks{1}.behavior.U.is_bypassed;

invariant_booleans = cellfun(@(x) x.behavior.S.is_invariant, invariants);
bypassed_booleans = cellfun(@(x) x.behavior.S.is_bypassed, invariants);


%% Initialize layer_S in generic case
if is_U_bypassed || is_U_single_scattered
    layer_S = layer_Y{1};
    start_index = 1;
else
    blurring_booleans = invariant_booleans & ...
        cellfun(@(x) strcmp(x.spec.invariance, 'blurred'), invariants);
    coordinates = 2 + ~blurring_booleans;
    start_index = 2;
    condition = true;
    while condition
        sub_Y = layer_Y{start_index};
        cell_Y = sub_Y{coordinates(1:start_index-1)};
        if isempty(cell_Y)
            condition = false;
            start_index = start_index - 1;
        elseif (start_index==(nBanks+1))
            condition = false;
        else
            start_index = start_index + 1;
        end
    end
    if start_index<2
        layer_S = layer_Y{1}{1};
    else
        layer_S = layer_Y{start_index}{coordinates(1:start_index-1)};
    end
end

%% Check that each variable defines a single invariant
has_multiple_invariants = any(invariant_booleans & bypassed_booleans);
if has_multiple_invariants
    error('Multiple invariants in Y_to_S not ready yet');
end

%% Iterated one-variable blurring or pooling
for variable_index = start_index:nInvariants
    invariant = invariants{variable_index};
    if strcmp(invariant.spec.invariance, 'blurred')
        layer_S = perform_ft(layer_S, invariant.behavior.key);
        layer_S = blur_Y(layer_S, invariant);
    elseif strcmp(invariant.spec.invariance, 'summed');
        layer_S = sum_Y(layer_S, invariant);
    end
end
end
