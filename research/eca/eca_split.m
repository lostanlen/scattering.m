function chunks = eca_split(y, N)
%% Pad y
y_length = length(y);
padded_length = 2^nextpow2(y_length);
y = cat(1, y, zeros(padded_length - length(y), 1));
y_length = length(y);

%% Initialize chunk matrix
hop_length = N / 2;
nChunks = y_length / hop_length;
chunks = zeros(N, nChunks);

%% Fill in chunks
% Case of first chunk
chunks((1+hop_length):N, 1) = y(1:hop_length);

% General case
for chunk_index = 2:(nChunks-1)
    chunk_start = (chunk_index-1) * hop_length + 1;
    chunk_stop = chunk_start + 2 * hop_length - 1;
    chunks(:, chunk_index) = y(chunk_start:chunk_stop);
end

% Case of last chunk
chunks(1:hop_length, end) = y((end-hop_length+1):end);

%% Window
w = hamming(N) / 1.08;
chunks = bsxfun(@times, w, chunks);
end