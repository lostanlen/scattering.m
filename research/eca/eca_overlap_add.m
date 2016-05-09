function y = eca_overlap_add(chunks)
%% Initialize y with zero
[N, nChunks] = size(chunks);

%% If there is only one chunk, return
if nChunks == 1
    y = chunks;
    return
end

%%
nHops_per_chunk = 4;
hop_length = N / nHops_per_chunk;
y_length = hop_length * (nChunks - nHops_per_chunk + 1);
y = zeros(y_length, 1);

for chunk_index = 1:nChunks
    chunk_start = (chunk_index-nHops_per_chunk) * hop_length + 1;
    chunk_stop = chunk_start + N - 1;
    if chunk_start < 1
        chunk_in = chunks((2-chunk_start):end, chunk_index);
        chunk_start = 1;
    elseif chunk_stop > y_length
        chunk_in = chunks(1:(end-chunk_stop+y_length), chunk_index);
        chunk_stop = y_length;
    else
        chunk_in = chunks(:, chunk_index);
    end
    y(chunk_start:chunk_stop) = y(chunk_start:chunk_stop) + chunk_in;
end
end