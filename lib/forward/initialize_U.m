function U0 = initialize_U(tensor,variable_names)
if nargin<3
    %% Automatic variable inference (for 1D and 2D only)
    tensor_sizes = size(tensor);
    U0 = initialize_variables_auto(tensor_sizes);
else
    %% Custom pattern matching of variable names
    U0 = initialize_variables_custom(variable_names);
end

%% Data storage and unpadding tree initialization
U0.data = tensor;

%% Alphanumeric ordering of field names
U0 = orderfields(U0);
end
