load('dictionaries.mat');
lambda2 = 7;
real_D = real(dicts.backward{lambda2});
imag_D = imag(dicts.backward{lambda2});
abs_D = log1p(10*abs(dicts.backward{lambda2}));
[nRows, nCols] = size(abs_D);


argmax = zeros(1, nCols);
for col_index = 1:nCols
    [m, argmax(col_index)] = max(abs_D(:, col_index));
end

[sorted_argmax, sorting_indices] = sort(argmax, 'descend');
sorted_abs_D = abs_D(:, sorting_indices);
subplot(111);
imagesc(sorted_abs_D)

%%
subplot(211);
sorted_real_D = real_D(:, sorting_indices);
imagesc(sorted_real_D);
subplot(212);
sorted_imag_D = imag_D(:, sorting_indices);
imagesc(sorted_imag_D);
