N = 4096;
sr = 512;
f1 = sr * 0.4568; % mother xi

clear opts;
opts{1}.time.size = N;
opts{1}.time.is_chunked = false;
opts{1}.time.max_Q = 4;
opts{1}.time.gamma_bounds = [1];
opts{2}.banks.time.wavelet_handle = @gammatone_1d;
opts{1}.max_scale = Inf;
opts{2}.banks.time.max_Q = 4;
opts{2}.banks.time.max_scale = Inf;
opts{2}.banks.time.wavelet_handle = @gammatone_1d;
opts{2}.invariants.time.invariance = 'summed';


archs = sc_setup(opts);

%
amplitudes = 2.^(-5:0.1:5);
frequencies = 1 - 2.^(0:-0.05:-12);
nAmplitudes = length(amplitudes);
nFrequencies = length(frequencies);

norm_ratios = zeros(nFrequencies, nAmplitudes);
t = (1:N)' / sr;

J2 = 31;
y = zeros(1+J2, nAmplitudes, nFrequencies);

for amplitude_index = 1:nAmplitudes
    for frequency_index = 1:nFrequencies
        amplitude = amplitudes(amplitude_index);
        frequency = frequencies(frequency_index);
        x1 = cos(2*pi*f1*t);
        x2 = amplitude * cos(2*pi*frequency*f1*t);
        x = x1 + x2;
        xs{frequency_index, amplitude_index} = x;
        %subplot(nAmplitudes, nFrequencies, (amplitude_index-1)*nFrequencies+frequency_index);
        %plot(x);
        %ylim([-1, 1])
        [S, U] = sc_propagate(x, archs);
        y(1, amplitude_index, frequency_index) =  norm(U{2}.data{1});
        for j2 = 1:J2
            y(1+j2, amplitude_index, frequency_index) = norm(U{3}.data{j2});
        end
        %[U_norm, layer_norms] = sc_norm(U);
        %norm_ratio = layer_norms(1+2) / layer_norms(1+1);
        %norm_ratios(frequency_index, amplitude_index) = norm_ratio;
    end
   amplitude_index
end
%
%%
clf();
f = figure(1);
set(f, 'WindowStyle', 'docked');
xlim([1, length(amplitudes)]);
ylim([1, length(frequencies)]);
set(gca(), 'YDir', 'normal');

color_order = jet();

h2 = {};

hold on;
for j2 = 3:4:30
    ratio = y(j2, :, :)./y(1,:,:);
    color = color_order(round(64/49 * (1+2*(j2-3))), :).';
    ratio_scaled = (ratio - min(ratio(:))) / (max(ratio(:)-min(ratio(:))));
    h = image(permute(bsxfun(@times, color, ratio), [3, 2, 1]));
    set(h, 'AlphaData', squeeze(ratio_scaled)'*1.0);
    hs{j2} = h;
end
hold off;

%
ylim([1, 221])
xticks(1:10:221);
xticklabels(log2(amplitudes(1:10:101)));
yticks(21:20:201);
yticklabels(log2(1-frequencies(21:20:201)));
set(gca(), 'linewidth', 1.0, 'gridalpha', 0.5, 'gridlinestyle', ':');
xlabel("Logarithme en base 2 de l'amplitude relative");
ylabel("Logarithme en base 2 de la différence de fréquence relative");
set(gca(), 'YDir', 'reverse');
grid('on');
set(gca(), 'FontName', 'Times New Roman');
set(gcf(),'color','w')
