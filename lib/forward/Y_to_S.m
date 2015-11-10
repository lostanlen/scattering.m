function layer_S = Y_to_S(layer_Y,arch)
%% Initialization
banks = arch.banks;
nBanks = length(banks);
invariants = arch.invariants;
nInvariants = length(invariants);
% This boolean is true at the last layer
is_U_bypassed = (length(layer_Y)==1);
% This boolean is true at the first layer (except for videos)
is_U_single_scattered = nBanks==1 && ...
    banks{1}.behavior.U.is_scattered && ...
    ~banks{1}.behavior.U.is_blurred && ...
    ~banks{1}.behavior.U.is_bypassed;

invariant_booleans = cellfun(@(x) x.behavior.S.is_invariant, invariants);
bypassed_booleans = cellfun(@(x) x.behavior.S.is_bypassed, invariants);

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

%% Check that S defines a single invariant
has_multiple_invariants = any(invariant_booleans & bypassed_booleans);
if has_multiple_invariants
    error('Multiple invariants in Y_to_S not ready yet');
end

%% Iterated one-variable blurring or pooling
for variable_index = start_index:nInvariants
    invariant = invariants{variable_index};
    if strcmp(invariant.spec.invariance, 'blurred')
        if iscell(layer_S)
            subsref_structure.type = '()';
            subsref_structure.subs = cat(2, ...
                replicate_colon(start_index-1), [1,3], ...
                replicate_colon(nInvariants-start_index));
            sub_layer_S = subsref(layer_S, subsref_structure);
            sub_layer_S = perform_ft(sub_layer_S, invariant.behavior.key);
            sub_layer_S = blur_Y(sub_layer_S, invariant);
            layer_S = subsasgn(layer_S, subsref_structure, sub_layer_S);
        else
            layer_S = perform_ft(layer_S, invariant.behavior.key);
            layer_S = blur_Y(layer_S, invariant);
        end
    elseif strcmp(invariant.spec.invariance, 'pooled');
        error('Nonlinear pooling not ready yet');
    end
end
end
