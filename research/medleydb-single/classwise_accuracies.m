function [accuracies, cm] = classwise_accuracies(Y_predicted, Y_true)
n_classes = max(Y_true);
cm = zeros(n_classes, n_classes);
for sample_index = 1:length(Y_predicted)
    cm(1 + Y_predicted(sample_index), 1 + Y_true(sample_index)) = ...
        cm(1 + Y_predicted(sample_index), 1 + Y_true(sample_index)) + 1;
end
accuracies = diag(cm) / sum(cm(:));
end
