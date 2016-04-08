function [iterations, init_loss, delta_signal] = eca_init(y, archs, opts)
%% Random initialization
if isfield(opts, 'initial_signal')
    init = opts.initial_signal;
else
    init = generate_colored_noise(y);
end
init = init - mean(init);
init = init * norm(init)/norm(init);
init = init + mean(init);

%% First forward
opts.signal_update = zeros(size(init));
opts.learning_rate = opts.initial_learning_rate;
S = cell(1, nLayers);
U = cell(1,nLayers);
Y = cell(1,nLayers);
U{1+0} = initialize_variables_auto(size(y));
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
delta_signal = sc_backpropagate(delta_S, U, Y, archs);

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