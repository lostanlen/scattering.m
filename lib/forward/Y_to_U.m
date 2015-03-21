function layer_U = Y_to_U(layer_Y_end,arch)
%%
nonlinearity = arch.nonlinearity;
routing_sizes = size(layer_Y_end);
mask = false(routing_sizes);
nRouting_subscripts = length(routing_sizes);
if nRouting_subscripts==2 && routing_sizes(2)==1
    nRouting_subscripts = 1;
end
subsref_structure.type = '()';
subsref_structure.subs = replicate_colon(nRouting_subscripts);
for routing_subscript = 1:nRouting_subscripts
    subsref_structure.subs{routing_subscript} = 1;
    mask = subsasgn(mask,subsref_structure,true);
    subsref_structure.subs{routing_subscript} = ':';
end
layer_U = apply_nonlinearity(nonlinearity,layer_Y_end,mask);
end
