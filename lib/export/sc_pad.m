function padded_tensor = sc_pad(tensor,variables)
%% Initialization
nVariables = length(variables);
tensor_sizes = size(tensor);
padded_tensor = tensor;
nTensor_dimensions = length(tensor_sizes);
is_real = isreal(tensor);

%% Padding along each variable
for variable_index = 1:nVariables
    variable = variables(variable_index);
    [padded_indices,conjugation_bools] = ...
        pad_variable(tensor_sizes,variable);
    subscripts = variable.subscripts;
    subsref_structure.type = '()';
    subsref_structure.subs = repmat({':'},1,nTensor_dimensions);
    subsref_structure.subs(subscripts) = padded_indices(:);
    padded_tensor = subsref(padded_tensor,subsref_structure);
    if variable.padding.is_zero
        padded_sizes = variable.original_sizes;
        subscripts = variable.subscripts;
        subsasgn_structure.type = '()';
        subsasgn_structure.subs = repmat({':'},1,nTensor_dimensions);
        subsasgn_structure.subs(subscripts) = num2cell(padded_sizes);
        padded_tensor = subsasgn(padded_tensor,subsasgn_structure,0);
    end
end

%% Padding conjugation is input is complex
if ~is_real
    for variable_index = 1:nVariables
        padded_tensor = ...
            conjugate_padding(padded_tensor,variable,conjugation_bools);
    end
end
end
