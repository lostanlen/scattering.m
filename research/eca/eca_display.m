function eca_display(x, archs)
%% Display waveform
subplot(211);
plot(x);

%% Display spectrogram
subplot(212);
N = archs{1}.banks{1}.spec.size;
chunks = eca_split(x, N);
U0 = initialize_variables_custom(size(chunks), {'time', 'chunk'});
U0.data = chunks;
Y1 = U_to_Y(U0, archs{1}.banks);
U1 = Y_to_U(Y1{end}, archs{1}.nonlinearity);
U1 = unchunk_layer(U1);
scalogram = display_scalogram(U1);
scalogram = scalogram(:, 1:length(x));
imagesc(log1p(scalogram./10.0));
colormap rev_gray;
end
