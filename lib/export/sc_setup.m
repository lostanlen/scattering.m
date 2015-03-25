function architectures = sc_setup(opts)
%%
plans = setup_plans(opts);
nLayers = length(plans);
architectures = cell(nLayers,1);
%%
for layer = 1:nLayers
    architecture = plans{layer};
    for variable_index = 1:length(architecture.banks)
        architecture.banks{variable_index} = ...
            setup_bank(architecture.banks{variable_index});
    end
    architectures{layer} = architecture;
end

end
