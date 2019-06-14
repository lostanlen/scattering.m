clf();
J = 7;
N = 2^J;
sample_rate = 22050;
t = (0:(N-1)) / sample_rate;
n_layers = J+1;
fourier_decay = 1;

n_partials_list = 1:(2^(J-1)) - 1;
n_signals = length(n_partials_list);
precision_str = 'double';

signal_norms = nan(n_layers, n_signals);

for signal_id = 1:n_signals
    disp(signal_id);
    
    n_partials = n_partials_list(signal_id);
    frequencies = 2*sample_rate/N * (1+ 1*(0:(n_partials-1)));
    n_partials = length(frequencies);
    amplitudes = 1./(1:n_partials).^fourier_decay;
    partials = zeros(N, n_partials, precision_str);
    for partial_id = 1:n_partials
        frequency = frequencies(partial_id);
        amplitude = amplitudes(partial_id);
        partials(:, partial_id) = amplitude * cos(2*pi*t*frequency);
    end
    U0 = fftshift(sum(partials, 2));
    U = cell(1+n_layers, 1);
    U{1+0} = U0;

    for layer_id = 1:n_layers
        Y_in_ft = fft(U{layer_id}, [], 1);
        Y_out_ft = zeros(cat(2, size(U{layer_id}), J-2), precision_str);
        subsref_structure = struct( ...
            'type', '()', 'subs', []);
        subsref_structure.subs = num2cell(repmat(':', layer_id+1, 1)).';
        subsasgn_structure = struct( ...
            'type', '()', 'subs', []);
        subsasgn_structure.subs = num2cell(repmat(':', layer_id+2, 1)).';
        for j = 1:(J-2)
            subsref_structure.subs{1} = (2^j:(2^(j+1)-1));
            subsasgn_structure.subs{1} = (2^j:(2^(j+1)-1));
            subsasgn_structure.subs{end} = j;
            Y_in_ft_sub = subsref(Y_in_ft, subsref_structure);
            Y_out_ft = subsasgn(Y_out_ft, subsasgn_structure, Y_in_ft_sub);
        end
        Y_out = ifft(Y_out_ft, [], 1);
        U{1+layer_id} = abs(Y_out);
        U{1+layer_id} = U{1+layer_id} .* U{1+layer_id};
    end

    S = cellfun(@(x) squeeze(sum(x, 1)), U, 'UniformOutput', false);

    
    for layer_id = 1:n_layers
        signal_norms(layer_id, signal_id) = norm(S{layer_id}(:));
    end
    %subplot(212);
    %plot(log10(signal_norms(signal_id, :)), '-o');
end

%%
clf();
colors = {
    [0.0000, 0.4470, 0.7410], ...
    [0.8500, 0.3250, 0.0980], ...
    [0.9290, 0.6940, 0.1250], ...
    [0.4940, 0.1840, 0.5560], 'k'};

hold on;
for j = 1:(J-2)
    signal_range = (2^j):(2^(j+1)-1);
    handle_visibility = 'on';
    for signal_id = signal_range
        plot( ...
            1:(n_layers-1), ...
            log10(signal_norms(2:end, signal_id).'), ...
            '-o', 'LineWidth', 1.5, 'Color', colors{j}, ...
            'DisplayName', ...
            pad(sprintf("%d", signal_id), 0, 'left') + " à " + pad(sprintf("%d", 2*signal_id-1), 0, 'left'), ...
            'HandleVisibility', handle_visibility);
        handle_visibility = 'off';
    end
    
end
hold off;

set(gca(), 'FontName', 'Times New Roman');
ylabel('Logarithme en base 10 de l''énergie');
xlabel('Profondeur de diffusion en ondelettes');
xlim([1, J]);
ylim([-150, 15]);
yticks((-150:25:25))
legend('Location', 'southwest');
grid();
set(gcf(), 'Color', 'none');

%plot(1:(n_layers-1), log10(signal_norms(2:end, :).'), '-o', 'LineWidth', 2);
%xticks(1:(n_layers-1))