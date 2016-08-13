function chunks = eca_split(y, N)
%% If y has length N, return
y_length = length(y);
if y_length == N;
    chunks = y;
    return
end
    
%% Pad y
nHops_per_chunk = 2;
hop_length = N / nHops_per_chunk;
padded_length = hop_length * ceil(y_length / hop_length);
y = cat(1, y, zeros(padded_length - length(y), 1));
y_length = length(y);

%% Initialize chunk matrix
nChunks = nHops_per_chunk - 1 + y_length / hop_length;
chunks = zeros(N, nChunks);

%% Fill in chunks
for chunk_index = 1:nChunks
    chunk_start = (chunk_index-nHops_per_chunk) * hop_length + 1;
    chunk_stop = chunk_start + N - 1;
    if chunk_start < 1
        chunks(:, chunk_index) = ...
            cat(1, zeros(1-chunk_start, 1), y(1:chunk_stop));
    elseif chunk_stop > y_length
        chunks(:, chunk_index) = ...
            cat(1, y(chunk_start:end), zeros(chunk_stop-y_length, 1));
    else
        chunks(:, chunk_index) = y(chunk_start:chunk_stop);
    end
end

%% Window
w = hann(N);
chunks = bsxfun(@times, w, chunks);
end