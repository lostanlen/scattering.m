function eca_display(x, archs)
%% Display waveform
subplot(211);
plot(x);

%% Display spectrogram
subplot(212);
U0 = initialize_U(x, archs{1}.banks{1});
Y1 = U_to_Y(U0, archs{1}.banks);
U1 = Y_to_U(Y1{end}, archs{1}.nonlinearity);
scalogram = display_scalogram(U1);
imagesc(log1p(scalogram./10.0));
colormap rev_gray;
end
