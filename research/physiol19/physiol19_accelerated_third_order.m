%%
signal = randn(5e6, 1);
S_batches = sc_propagate(signal, archs);

% Custom post-processing loop: fused reduction, unchunking, and formatting
nBatches = size(S_batches, 1);
S_cell = cell(nBatches, 3);
t_start = 1 + 0.25*size(S_batches{1,2}{1}.data, 1);
t_stop = 0.75*size(S_batches{1,2}{1}.data, 1);

for batch_id = 1:nBatches

    % First order.
    S1_tensor = S_batches{batch_id, 1+1}{1}.data(t_start:t_stop, :, :);
    S_cell{batch_id, 1} = reshape(S1_tensor, ...
        [size(S1_tensor, 1)*size(S1_tensor, 2), size(S1_tensor, 3)]);
    
    % Second order.
    S2_temp = cellfun( ...
        @(x) reshape(x(t_start:t_stop, :, :), ...
        [(t_stop-t_start+1)*size(x, 2), size(x, 3)]), ...
        S_batches{batch_id,1+2}{1}.data, 'UniformOutput', false);
    S_cell{batch_id, 2} = [S2_temp{:}];
    
    % Third order.
    J3 = length(S_batches{1,1+3}{1}.data);
    S3_temp = cell(1, J3);
    for j3 = 1:J3
        S3_j3 = cellfun( ...
            @(x) reshape(x(t_start:t_stop, :, :), ...
            [(t_stop-t_start+1)*size(x, 2), size(x, 3)]), ...
            S_batches{batch_id,1+3}{1}.data{j3}, 'UniformOutput', false);
        S3_temp{j3} = [S3_j3{:}];
    end
    S_cell{batch_id, 3} = [S3_temp{:}];
end

S_mats = cell(1, 3);
for layer_id = 1:3
    S_mats{layer_id} =  cat(1, S_cell{:, layer_id});
end
S_mat = [S_mats{:}];