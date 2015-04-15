function layer_U = Y_to_U(layer_Y_end,arch)
%%
nonlinearity = arch.nonlinearity;
routing_sizes = drop_trailing(size(layer_Y_end),1);
mask = false(routing_sizes);
nRouting_subscripts = length(routing_sizes);
subsref_structure = substruct('()',replicate_colon(nRouting_subscripts));
for routing_subscript = 1:nRouting_subscripts
    subsref_structure.subs{routing_subscript} = 1;
    mask = subsasgn(mask,subsref_structure,true);
    subsref_structure.subs{routing_subscript} = ':';
end
layer_U = apply_nonlinearity(nonlinearity,layer_Y_end,mask);
end
