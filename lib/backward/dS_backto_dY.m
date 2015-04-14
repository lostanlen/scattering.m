function layer_dY = dS_backto_dY(layer_dS,arch)
%% Initialization
nVariables_to_transform = length(arch.banks);
banks = arch.banks;

%% Backpropagate last variable
start_index = nVariables_to_transform;
while banks{start_index}.behavior.S.is_bypassed
    start_index = start_index - 1;
end
layer_dY{start_index} = dual_blur_dY(layer_dS,banks{start_index});
layer_dY{start_index} = ...
    perform_ift(layer_dY{start_index},banks{start_index}.behavior.key);

%% Multi-variable case : iterated one-variable backpropagation
% Wrapping the for loop inside an if statement yields an easy speed gain
if start_index1
    for variable_index = (start_index-1):-1:1
        bank = banks{variable_index};
        layer_dY{variable_index} = ...
            dual_blur_dY(layer_dY{variable_index+1},bank);
        key = bank.behavior.key;
        layer_dY{variable_index} = perform_ift(layer_dY{variable_index},key);
    end
end
end