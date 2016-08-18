function [init, init_loss, delta_chunks] = eca_init(y, target_S, archs, opts)
%% Random initialization
[N, nChunks] = size(y);
if isfield(opts, 'initial_signal')
    if nChunks > 1
        init = eca_split(opts.initial_signal, N);
    else
        init = opts.initial_signal;
    end
else
    init = eca_split(generate_colored_noise(eca_overlap_add(y)), N);
end

%% First forward
opts.signal_update = zeros(size(init));
opts.learning_rate = opts.initial_learning_rate;
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1,nLayers);
Y = cell(1,nLayers);
if nChunks > 1
    U{1+0} = initialize_variables_custom(size(y), {'time', 'chunk'});
else
    U{1+0} = initialize_variables_auto(size(y));
end
U{1+0}.data = init;
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    if isfield(arch, 'banks')
        Y{layer} = U_to_Y(U{1+previous_layer}, arch.banks);
    else
        Y{layer} = U(1+previous_layer);
    end
    if isfield(arch, 'nonlinearity')
        U{1+layer} = Y_to_U(Y{layer}{end}, arch.nonlinearity);
    end
    if isfield(arch, 'invariants')
        S{1+previous_layer} = Y_to_S(Y{layer}, arch);
    end
end

%% First backward
delta_S = sc_substract(target_S, S);
init_loss = sc_norm(delta_S);
delta_chunks = sc_backpropagate(delta_S, U, Y, archs);
delta_signal = eca_overlap_add(delta_chunks);
delta_chunks = eca_split(delta_signal, N);
end