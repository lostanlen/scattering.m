function light_archs = lighten_archs(archs)
nLayers = length(archs);
light_archs = archs;
for layer_index = 1:nLayers
    arch = archs{layer_index};
    nBanks = length(arch.banks);
    for bank_index = 1:nBanks
        arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'psis');
        arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'phi');
        if arch{bank_index}.spec.has_duals
            arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'dual_psis');
            arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'dual_phi');
        end
    end
    light_archs{layer_index} = arch;
end
end

