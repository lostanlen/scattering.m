function iterations = eca_synthesize(y, archs, opts)
%% Default options
opts.is_displayed = true;
opts = fill_reconstruction_opt(opts);

%% Divide into chunks
N = archs{1}.banks{1}.spec.size;
target_chunks = eca_split(y, N);

%% Forward propagation of target signal
target_S = eca_target(target_chunks, archs);
[target_norm, layer_target_norms] = sc_norm(target_S);
nLayers = length(archs);

%% Initialization
[iterations, previous_loss, delta_chunks] = ...
    eca_init(target_chunks, target_S, archs, opts);
previous_chunks = eca_split(iterations{1+0}, N);
relative_loss_chart = zeros(opts.nIterations, 1);
opts.signal_update = zeros(size(target_chunks));
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
    new_chunks = update_reconstruction(previous_chunks, delta_chunks, opts);
    iterations{1+iteration} = eca_overlap_add(new_chunks);
    
    %% Scattering propagation
    S = cell(1, nLayers);
    U = cell(1,nLayers);
    Y = cell(1,nLayers);
    U{1+0} = ...
        initialize_variables_custom(size(target_chunks), {'time', 'chunk'});
    U{1+0}.data = new_chunks;
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
        if failure_counter > 3
            opts.learning_rate = opts.initial_learning_rate;
        else
            continue
        end
    end
    
    %% If loss has decreased, step confirmation and bold driver "acceleration"
    iteration = iteration + 1;
    failure_counter = 0;
    relative_loss_chart(iteration) = 100 * loss / target_norm;
    previous_chunks = eca_split(iterations{iteration}, N);
    previous_loss = loss;
    opts.signal_update = ...
        opts.momentum * opts.signal_update + ...
        opts.learning_rate * delta_chunks;
    opts.learning_rate = ...
        opts.bold_driver_accelerator * ...
        opts.learning_rate;
    
    %% Backpropagation
    delta_chunks = sc_backpropagate(delta_S, U, Y, archs);
    
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
    U = sc_unchunk(U(1:2));
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

end

