function architectures = sc_setup(opts)
%%
plans = setup_plans(opts);
nLayers = length(plans);
architectures = cell(nLayers,1);
%%
for layer = 1:nLayers
    architecture = plans{layer};
    if isfield(architecture, 'banks')
        for bank_index = 1:length(architecture.banks)
            architecture.banks{bank_index} = ...
                setup_bank(architecture.banks{bank_index});
        end
    end
    if isfield(architecture, 'invariants')
        for invariant_index = 1:length(architecture.invariants)
            architecture.invariants{invariant_index} = ...
                setup_invariant(architecture.invariants{invariant_index});
        end
    end
    architectures{layer} = architecture;
end

end
