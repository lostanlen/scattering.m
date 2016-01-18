function light_archs = lighten_archs(archs)
nLayers = length(archs);
light_archs = archs;
for layer_index = 1:nLayers
    arch = archs{layer_index};
    if isfield(arch, 'banks')
        nBanks = length(arch.banks);
    else
        nBanks = 0;
    end
    for bank_index = 1:nBanks
        arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'psis');
        arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'phi');
        if arch.banks{bank_index}.spec.has_duals
            arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'dual_psis');
            arch.banks{bank_index} = rmfield(arch.banks{bank_index}, 'dual_phi');
        end
    end
    if isfield(arch, 'invariants')
        nInvariants = length(arch.invariants);
    else
        nInvariants = 0;
    end
    for invariant_index = 1:nInvariants
        arch.invariants{invariant_index} = ...
            rmfield(arch.invariants{invariant_index}, 'phi');
        if arch.invariants{invariant_index}.spec.has_duals
            arch.invariants{invariant_index} = ...
                rmfield(arch.invariants{invariant_index}, 'dual_phi');
        end
    end
    light_archs{layer_index} = arch;
end
end

