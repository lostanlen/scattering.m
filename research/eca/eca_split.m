function chunks = eca_split(y, N)
%% If y has length N, return
y_length = length(y);
if y_length == N;
    chunks = y;
    return
end
    
%% Pad y
hop_length = N / 2;
padded_length = hop_length * ceil(y_length / hop_length);
y = cat(1, y, zeros(padded_length - length(y), 1));
y_length = length(y);

%% Initialize chunk matrix
hop_length = N / 2;
nChunks = 1 + y_length / hop_length;
chunks = zeros(N, nChunks);

%% Fill in chunks
% Case of first chunk
chunks((1+hop_length):N, 1) = y(1:hop_length);

% General case
for chunk_index = 2:(nChunks-1)
    chunk_start = (chunk_index-2) * hop_length + 1;
    chunk_stop = chunk_start + 2 * hop_length - 1;
    chunks(:, chunk_index) = y(chunk_start:chunk_stop);
end

% Case of last chunk
chunks(1:hop_length, end) = y((end-hop_length+1):end);

%% Window
w = hann(N);
chunks = bsxfun(@times, w, chunks);
end