function y = eca_overlap_add(chunks)
%% Initialize y with zero
[N, nChunks] = size(chunks);
hop_length = N/2;
y_length = hop_length * (nChunks - 1);
y = zeros(y_length, 1);

% Case of first chunk
y(1:hop_length) = chunks((1+hop_length):end, 1);

% General case
for chunk_index = 2:(nChunks-1)
    chunk_start = (chunk_index-2) * hop_length + 1;
    chunk_stop = chunk_start + 2 * hop_length - 1;
    y(chunk_start:chunk_stop) = ...
        y(chunk_start:chunk_stop) + ...
        chunks(:, chunk_index);
end

% Case of last chunk
y((end-hop_length+1):end) = ...
    y((end-hop_length+1):end) + ...
    chunks((1:hop_length), end);
end