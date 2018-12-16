function architectures = sc_setup(opts)
%%
plans = setup_plans(opts);
nPlans = length(plans);
is_lastlayer_implicit = isfield(plans{end}, 'banks');
nLayers = length(plans) + is_lastlayer_implicit;
architectures = cell(nLayers, 1);
%%
for plan_index = 1:nPlans
    architecture = plans{plan_index};
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
    architectures{plan_index} = architecture;
end

if is_lastlayer_implicit && isfield(architectures{end-1}, 'invariants')
    architectures{end}.invariants = architectures{end-1}.invariants;
end

if ~isfield(opts{1}, 'etc')
    opts{1}.etc = struct();
end
architectures{1}.etc = fill_etc(opts{1}.etc);

end
