function [value,structure] = default(structure,field,default_value)
if ~isfield(structure,field) || isempty(structure.(field))
	structure.field = default_value;
    value = default_value;
else
    value = structure.(field);
end
end
