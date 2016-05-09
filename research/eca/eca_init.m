function [iterations, init_loss, delta_chunks] = ...
    eca_init(y, target_S, archs, opts)
%% Random initialization
[N, nChunks] = size(y);
if isfield(opts, 'initial_signal')
    if nChunks > 1
        init = eca_split(opts.initial_signal, N);
    else
        init = opts.initial_signal;
    end
else
    init = zeros(size(y));
    for chunk_index = 1:nChunks
        init(:, chunk_index) = generate_colored_noise(y(:, chunk_index));
    end
end

%% Standardization 
for chunk_index = 1:nChunks
    init_chunk = init(:, chunk_index);
    y_chunk = y(:, chunk_index);
    init_chunk = init_chunk - mean(init_chunk);
    init_chunk = init_chunk * norm(y_chunk) / (eps() + norm(init_chunk));
    init_chunk = init_chunk + mean(y_chunk);
    init(:, chunk_index) = init_chunk;
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

%% Unchunking if required
if nChunks > 1
    U = U(1:2);
    U = sc_unchunk(U);
    init = eca_overlap_add(init);
    init = eca_split(init, N);
    init = eca_overlap_add(init);
end

%% First display and sonification
figure_handle = figure(1);
colormap rev_gray;
set(figure_handle, 'WindowStyle', 'docked');
subplot(211);
plot(init);
subplot(212);
scalogram = display_scalogram(U{1+1});
imagesc(log1p(scalogram./10.0));
if opts.is_sonified
    soundsc(init, 44100);
end

%%
iterations = cell(1, opts.nIterations);
iterations{1+0} = init;

end