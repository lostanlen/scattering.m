function data_ft = reshape_spiral(data_ft,bank)
%% Cell-wise dispatch
data_ft_sizes = size(data_ft);
if iscell(data_ft)
    data_ft_sizes = size(data_ft);
    nCells = prod(data_ft_sizes);
    for cell_index = 1:nCells
        data_ft{cell_index} = reshape_spiral(data_ft{cell_index},bank);
    end
    data_ft = reshape(data_ft,data_ft_sizes);
    return;
end

spiral = bank.behavior.spiral;
gamma_subscript = spiral.subscript;
nChromas_per_octave = pow2(spiral.nChromas,spiral.chroma_log2_sampling);
input_nGammas = data_ft_sizes(gamma_subscript);
input_nOctaves = input_nGammas / nChromas_per_octave;
output_nOctaves = ...
    pow2(nextpow2(spiral.octave_padding_length + input_nOctaves) - 1);
output_nGammas = nChromas_per_octave * output_nOctaves;
padding_sizes = data_ft_sizes;
padding_sizes(gamma_subscript) = output_nGammas - input_nGammas;
padded_data_ft = cat(gamma_subscript,data_ft,zeros(padding_sizes));
spiraled_sizes = [data_ft_sizes(1:(gamma_subscript-1)), ...
    nChromas_per_octave,output_nOctaves, ...
    data_ft_sizes((gamma_subscript+1):end)];
data_ft = reshape(padded_data_ft,spiraled_sizes);
end
