%% Setup wavelet filterbanks.
% Import toolboxes.
clc();
clear();

addpath(genpath('~/scattering.m'));
addpath(genpath('~/export_fig'));

N = 131072;
Q1 = 24;
J = 11;
T = 2^J;

% Synthesize chirps.
x = cat(1, ...
    repmat(dafx_synthesize_chirps(N/8), 7, 1), zeros(N/8, 1));

% Setup time-frequency scattering operators.
archs = dafx_setup(N, Q1, T);

% Compute time-frequency scattering.
[S, U] = sc_propagate(x, archs);


%% Reverse chirps.
S_rev = S;
nTemporal_scales = length(S{1+2}{1,1}.data);
sigma = 2.0;
        
for j2_tm = 1:nTemporal_scales
    nFrequency_scales = length(S{1+2}{1,1}.data{j2_tm});
    
    for j_fr = 1:nFrequency_scales
        forward_slice = S{1+2}{1,1}.data{j2_tm}{j_fr};
        backward_slice = S_rev{1+2}{1,1}.data{j2_tm}{j_fr}(:, :, 2:-1:1);
        
        n_times = size(forward_slice, 1);
        sigmoid = 1 ./ (1 + exp(- 2.0 * linspace(-2.5, 5.5, n_times).'));
        
        sigmoid_slice = ...
            bsxfun(@times, (1-sigmoid), forward_slice) + ...
            bsxfun(@times, sigmoid, backward_slice);
        

        sigmoid_slice_ft = fft(sigmoid_slice, [], 2);
        omega = 0:(size(sigmoid_slice, 2)-1);
        gauss_ft = exp(-omega.*omega / (2*sigma^2));
        gauss_ft(2:end) = (gauss_ft(2:end) + gauss_ft(end:-1:2));
        
        sigmoid_slice_ft = bsxfun(@times, sigmoid_slice_ft, gauss_ft);
        blurred_slice = ifft(sigmoid_slice_ft, [], 2);
        
        %S_rev{1+2}{1,1}.data{j2_tm}{j_fr} = blurred_slice;
        %S_rev{1+2}{1,1}.data{j2_tm}{j_fr} = sigmoid_slice;
            
    end
end


omega = 0:(size(S{1+1}.data, 2)-1);
gauss_ft = exp(-omega.*omega / (2*sigma^2));
gauss_ft(2:end) = (gauss_ft(2:end) + gauss_ft(end:-1:2));

S1_slice_ft = fft(S{1+1}.data, [], 2);
S1_slice_ft = bsxfun(@times, S1_slice_ft, gauss_ft);
S1_slice = ifft(S1_slice_ft, [], 2);

S_rev{1+1}.data = S1_slice;

%% Reconstruct signal.
target_S = S_rev;

% Default options.
rec_opts = struct();
rec_opts.is_spectrogram_displayed = true;
rec_opts.is_sonified = false;
rec_opts.sample_rate = 8192;
rec_opts.nIterations = 300;
rec_opts = fill_reconstruction_opt(rec_opts);

% Computation of norm.
[target_norm, layer_target_norms] = sc_norm(target_S);
nLayers = length(archs);

% Initialization
[x_noise, previous_loss, delta_signal] = ...
    eca_init(x, target_S, archs, rec_opts);
x_ft = fft(x);
x_ft((1+(end/2)):end) = 0;
x_hilbert = 2 * ifft(x_ft);
x_amplitude = abs(x_hilbert);
x_modulated = x_amplitude .* x_noise;
y = x_modulated / norm(x);

%
iterations = cell(1, rec_opts.nIterations);
iterations{1+0} = y;
previous_signal = iterations{1+0};
relative_loss_chart = zeros(1, rec_opts.nIterations);
relative_layer_loss_chart = zeros(nLayers, rec_opts.nIterations);
signal_update = zeros(size(iterations{1+0}));
learning_rate = rec_opts.initial_learning_rate;
max_nDigits = 1 + floor(log10(rec_opts.nIterations));
sprintf_format = ['%0.', num2str(max_nDigits), 'd'];


% Iterated reconstruction
iteration = 1;
failure_counter = 0;
is_display_active = rec_opts.is_spectrogram_displayed;
if is_display_active
    figure_handle = gcf();
    set(figure_handle, 'WindowStyle', 'docked');
end
if rec_opts.is_verbose
    tic();
end

while (iteration <= rec_opts.nIterations) && ...
        (~rec_opts.is_spectrogram_displayed || is_display_active)
    % Signal update
    y = ...
        update_reconstruction(previous_signal, ...
        delta_signal, ...
        signal_update, ...
        learning_rate, ...
        rec_opts);
    
    % Griffin-Lim.
    if mod(iteration, 10) == 0
        %iterations{1+iteration} = y;
        y_ft = fft(y);
        y_ft((1+(end/2)):end) = 0;
        y_hilbert = 2 * ifft(y_ft);
        y_amplitude = abs(y_hilbert);
        y = (0.5 + 0.5 * (x_amplitude ./ y_amplitude)) .* y;
        iterations{1+iteration} = y * norm(x) / norm(y);
        %soundsc(y);
        
    else
        iterations{1+iteration} = y;
    end

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
    if rec_opts.adapt_learning_rate && (loss > previous_loss)
        learning_rate = ...
            rec_opts.bold_driver_brake * learning_rate;
        signal_update = ...
            rec_opts.bold_driver_brake * signal_update;
        if rec_opts.is_verbose
            disp(['Learning rate = ', num2str(learning_rate)]);
        end
        failure_counter = failure_counter + 1;
        if failure_counter > 3
            learning_rate = rec_opts.initial_learning_rate;
        else
            continue
        end
    end

    % If loss has decreased, step confirmation and acceleration
    iteration = iteration + 1;
    failure_counter = 0;
    relative_loss_chart(iteration) = 100 * loss / target_norm;
    relative_layer_loss_chart(:, iteration) = ...
        100 * layer_absolute_distances / target_norm;
    previous_signal = iterations{iteration};
    previous_loss = loss;
    signal_update = ...
        rec_opts.momentum * signal_update + ...
        learning_rate * delta_signal;
    learning_rate = ...
        rec_opts.bold_driver_accelerator * ...
        learning_rate;

    % Backpropagation
    delta_signal = sc_backpropagate(delta_S, U, Y, archs);

    % Pretty-printing of scattering distances and loss function
    if rec_opts.is_verbose
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
        imagesc(log1p(scalogram./10.0));
        colormap rev_magma;
        drawnow();
        is_display_active = ishandle(figure_handle);
    end

    % Sonify
    if rec_opts.is_sonified
        soundsc(iterations{iteration}, rec_opts.sample_rate);
    end
end
if rec_opts.is_verbose
    toc();
end


%%
figure();

subplot(211);
[S, target_U] = sc_propagate(x, archs);
orig_scalogram = display_scalogram(target_U{1+1});
imagesc(log1p(orig_scalogram(10:50, 1:(8192*5))./100.0));
axis off;
subplot(212);
scalogram = display_scalogram(U{1+1});
imagesc(log1p(scalogram(10:50, 1:(8192*5))./100.0));
axis off;
colormap rev_magma