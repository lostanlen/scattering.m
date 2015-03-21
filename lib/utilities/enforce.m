function value = enforce(structure,field,enforced_value)
if ~isfield(structure,'field')
    value = enforced_value;
else
    if isstring(enforced_value)
        if ~strcmp(structure.(field),enforced_value)
            warning(['Enforced redefinition of optional field %s', ...
                     ' with value "%s" (previously %s)'], ...
                     field,enforced_value,structure.(field));
        end
        return;
    end
    if isnumeric(enforced_value);
        if ~isequal(structure.(field),enforced_value)
            warning(['Enforced redefinition of optional field %s', ...
                     ' with value "%d" (previously %d)'], ...
                     field,enforced_value,structure.(field));
        end
    end
    value = enforced_value;
end
end

