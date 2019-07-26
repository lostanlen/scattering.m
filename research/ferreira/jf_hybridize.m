Q1 = 24;
T = 2^13; % you can try 2^(14), 2^(15), 2^(16)
is_sonified = true;
modulations = 'time-frequency';
wavelets = 'morlet';
N = 2^17;
archs = eca_setup_1chunk(Q1, T, modulations, wavelets, N);
archs{1}.banks{1}.behavior.gamma_bounds = [1, 128];

%%
[x, sr] = audioread('jf_voice.wav');
[Sx, Ux] = sc_propagate(x, archs);

[y, ~] = audioread('jf_wind.wav');
[Sy, Uy] = sc_propagate(y.*planck_taper(N), archs);

%%
Sz = Sx;
Sz{1+2} = Sy{1+2};
% for j2 = 1:length(Sz{1+2}{1}.data)
%     for j_fr = 1:length(Sz{1+2}{1,1}.data{j2})
%         j1_bounds = Sx{1+2}{1,1}.ranges{1}{j2}{j_fr}(:, 2);
%         j1_range = j1_bounds(1):j1_bounds(2):j1_bounds(3);
%         s1_x = Sx{1+1}.data(:, j1_range);
%         s1_y = Sy{1+1}.data(:, j1_range);
%         s2_x = Sx{1+2}{1,1}.data{j2}{j_fr}(:, 1:length(j1_range), :);
%         Sz{1+2}{1,1}.data{j2}{j_fr}(:, 1:length(j1_range), :) = ...
%             bsxfun(@times, s2_x, s1_y./s1_x);
%     end
%     j1_bounds = Sx{1+2}{1,2}.ranges{1}{j2}(:, 2);
%     j1_range = j1_bounds(1):j1_bounds(2):j1_bounds(3);
%     s1_x = Sx{1+1}.data(:, j1_range);
%     s1_y = Sy{1+1}.data(:, j1_range);
%     s2_x = Sx{1+2}{1,2}.data{j2}(:, 1:length(j1_range), :);
%     Sz{1+2}{1,2}.data{j2}(:, 1:length(j1_range), :) = ...
%         bsxfun(@times, s2_x, s1_y./s1_x);
% end

%% Default options
opts = struct( ...
    'is_spectrogram_displayed', true, 'is_sonified', is_sonifiedonifie, ...
    'nIterations', 25, 'sample_rate', 22050);
opts = fill_reconstruction_opt(opts);

% Forward propagation of target signal
target_S = Sz;
[target_norm, layer_target_norms] = sc_norm(target_S);
nLayers = length(archs);

%% Initialization
[init, previous_loss, delta_signal] = ...
    eca_init(y, target_S, archs, opts);
iterations = cell(1, opts.nIterations);
iterations{1+0} = init;
previous_signal = iterations{1+0};
relative_loss_chart = zeros(1, opts.nIterations);
relative_layer_loss_chart = zeros(nLayers, opts.nIterations);
signal_update = zeros(size(iterations{1+0}));
learning_rate = opts.initial_learning_rate;
max_nDigits = 1 + floor(log10(opts.nIterations));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];

%% Iterated reconstruction
iteration = 1;
failure_counter = 0;
is_display_active = opts.is_spectrogram_displayed;
if is_display_active
    figure_handle = gcf();
    set(figure_handle, 'WindowStyle', 'docked');
end
if opts.is_verbose
    tic();
end

while (iteration <= opts.nIterations) && (~opts.is_spectrogram_displayed || is_display_active)
    % Signal update
    iterations{1+iteration} = ...
        update_reconstruction(previous_signal, ...
        delta_signal, ...
        signal_update, ...
        learning_rate, ...
        opts);

    % Scattering propagation
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

    % Measurement of distance to target in the scattering domain
    delta_S = sc_substract(target_S,S);

    % If loss has increased, step retraction and bold driver "brake"
    [loss, layer_absolute_distances] = sc_norm(delta_S);
    if opts.adapt_learning_rate && (loss > previous_loss)
        learning_rate = ...
            opts.bold_driver_brake * learning_rate;
        signal_update = ...
            opts.bold_driver_brake * signal_update;
        if opts.is_verbose
            disp(['Learning rate = ', num2str(learning_rate)]);
        end
        failure_counter = failure_counter + 1;
        if failure_counter > 3
            learning_rate = opts.initial_learning_rate;
        else
            continue
        end
    end

    % If loss has decreased, step confirmation and bold driver "acceleration"
    iteration = iteration + 1;
    failure_counter = 0;
    relative_loss_chart(iteration) = 100 * loss / target_norm;
    relative_layer_loss_chart(:, iteration) = ...
        100 * layer_absolute_distances / target_norm;
    previous_signal = iterations{iteration};
    previous_loss = loss;
    signal_update = ...
        opts.momentum * signal_update + ...
        learning_rate * delta_signal;
    learning_rate = ...
        opts.bold_driver_accelerator * ...
        learning_rate;

    % Backpropagation
    delta_signal = sc_backpropagate(delta_S, U, Y, archs);

    % Pretty-printing of scattering distances and loss function
    if opts.is_verbose
        pretty_iteration = sprintf(sprintf_format, iteration);
        layer_distances = ...
            100 * layer_absolute_distances ./ layer_target_norms;
        pretty_distances = num2str(layer_distances(2:end), '%8.2f%%');
        pretty_loss = sprintf('%.2f%%', relative_loss_chart(iteration));
        iteration_string = ['it = ', pretty_iteration, '  ;  '];
        distances_string = ...
            ['S_m distances = [ ',pretty_distances, ' ]  ;  '];
        loss_string = ['Loss = ', pretty_loss];
        disp([iteration_string, distances_string, loss_string]);
        disp(['Learning rate = ', num2str(learning_rate)]);
        toc();
        tic();
    end

    % Display
    if is_display_active
        subplot(211);
        plot(iterations{iteration});
        subplot(212);
        U = sc_unchunk(U(1:2));
        scalogram = display_scalogram(U{1+1});
        imagesc(log1p(scalogram));
        colormap rev_magma;
        drawnow();
        is_display_active = ishandle(figure_handle);
    end

    % Sonify
    if opts.is_sonified
        soundsc(iterations{iteration}, opts.sample_rate);
    end
end
if opts.is_verbose
    toc();
end