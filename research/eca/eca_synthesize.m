function iterations = eca_synthesize(y, archs, opts)
%% Default options
opts.is_displayed = true;
opts = fill_reconstruction_opt(opts);

%% Forward propagation of target signal
target_S = eca_target(y, archs);
[target_norm, layer_target_norms] = sc_norm(target_S);
nLayers = length(archs);

%% Initialization
[iterations, previous_loss, delta_signal] = eca_init(y, target_S, archs, opts);
previous_signal = iterations{1+0};
relative_loss_chart = zeros(opts.nIterations, 1);
opts.signal_update = zeros(size(iterations{1+0}));
opts.learning_rate = opts.initial_learning_rate;
max_nDigits = 1 + floor(log10(opts.nIterations));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
figure_handle = gcf();
tic();
while (iteration <= opts.nIterations) && ishandle(figure_handle)
    %% Signal update
    iterations{1+iteration} = ...
        update_reconstruction(previous_signal, delta_signal, opts);
    
    %% Scattering propagation
    S = cell(1, nLayers);
    U = cell(1,nLayers);
    Y = cell(1,nLayers);
    U{1+0} = initialize_variables_auto(size(y));
    U{1+0}.data = iterations{1+iteration};
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
    
    %% Measurement of distance to target in the scattering domain
    delta_S = sc_substract(target_S,S);
    
    %% If loss has increased, step retraction and bold driver "brake"
    [loss,layer_absolute_distances] = sc_norm(delta_S);
    if opts.adapt_learning_rate && (loss > previous_loss)
        opts.learning_rate = ...
            opts.bold_driver_brake * opts.learning_rate;
        opts.signal_update = ...
            opts.bold_driver_brake * opts.signal_update;
        disp(['Learning rate = ', num2str(opts.learning_rate)]);
        failure_counter = failure_counter + 1;
        if failure_counter < 10
            continue
        else
            disp('Too many retracted steps. Resuming algorithm.');
            iteration = 0;
            failure_counter = 0;
            [iterations, previous_loss, delta_signal] = ...
                eca_init(y, target_S, archs, opts);
            previous_signal = iterations{1+0};
            relative_loss_chart = zeros(opts.nIterations, 1);
            opts.signal_update = zeros(size(iterations{1+0}));
            opts.learning_rate = opts.initial_learning_rate;
            continue
        end
    end
    
    %% If loss has decreased, step confirmation and bold driver "acceleration"
    iteration = iteration + 1;
    failure_counter = 0;
    relative_loss_chart(iteration) = 100 * loss / target_norm;
    previous_signal = iterations{iteration};
    previous_loss = loss;
    opts.signal_update = ...
        opts.momentum * opts.signal_update + ...
        opts.learning_rate * delta_signal;
    opts.learning_rate = ...
        opts.bold_driver_accelerator * ...
        opts.learning_rate;
    
    %% Backpropagation
    delta_signal = sc_backpropagate(delta_S, U, Y, archs);
    
    %% Pretty-printing of scattering distances and loss function
    if opts.is_verbose
        pretty_iteration = sprintf(sprintf_format, iteration);
        layer_distances = ...
            100 * layer_absolute_distances ./ layer_target_norms;
        pretty_distances = num2str(layer_distances(2:end), '%8.2f%%');
        pretty_loss = sprintf('%.2f%%',relative_loss_chart(iteration));
        iteration_string = ['it = ', pretty_iteration, '  ;  '];
        distances_string = ...
            ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
        loss_string = ['Loss = ', pretty_loss];
        disp([iteration_string, distances_string, loss_string]);
        disp(['Learning rate = ', num2str(opts.learning_rate)]);
        toc();
        tic();
    end
    
    %% Display
    subplot(211);
    plot(iterations{iteration});
    subplot(212);
    scalogram = display_scalogram(U{1+1});
    imagesc(log1p(scalogram./10.0));
    colormap rev_gray;
    drawnow();
    
    %% Sonify
    if opts.is_sonified
        soundsc(iterations{iteration}, 44100);
    end
end
toc();

%% In case of early stopping, remove empty iterations
iterations = iterations(cellfun(@(x) ~isempty(x), iterations));
end