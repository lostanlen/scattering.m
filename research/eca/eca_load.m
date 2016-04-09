function [y, sample_rate, bit_depth] = eca_load(audio_path, N)
[y, sample_rate] = audioread(audio_path, 'native');
switch class(y)
    case 'int16'
        bit_depth = 16;
        y = double(y) / 2^16;
    case 'int32'
        bit_depth = 24;
        y = double(y) / 2^32;
end
if size(y, 2) == 2
    y = 0.5 * sum(y, 2);
end
if length(y) < N
    y = cat(1, y, zeros(N - length(y), 1));
else
    y = y(1:N);
end
end