addpath(genpath('../..'));
data_dir = '/scratch/vl1019/hecker_formulations_data';
files = list_dir(data_dir);
file_names = {files.name};
file_names = sort(file_names);
n_files = length(file_names);

Q1 = 12;
T = 2^8;
modulations = 'time-frequency';
wavelets = 'morlet';
archs = eca_setup(Q1, T, modulations, wavelets);

file_id = 1;

file_name = file_names{file_id};
file_path = fullfile(data_dir, file_name);
[waveform, sample_rate] = audioread(file_path);
waveform_length = length(waveform);
n_chunks = floor(waveform_length / N);
S_chunks = cell(1, n_chunks);

tic();
chunk_id = 0;
for chunk_id = 0:(n_chunks-1)
    chunk_start = 1 + N * chunk_id;
    chunk_stop = N * (chunk_id+1);
    waveform_chunk = waveform(chunk_start:chunk_stop);
    S_chunk = sc_propagate(waveform_chunk, archs);
    S_chunks{1+chunk_id} = S_chunk;
    disp(chunk_id);
end
toc();

function [text, S_sorted_paths] = eca_text(S_batches, nLines, sample_rate)
nBatches = length(S_batches);
S_batch_norms = cell(1, nBatches);
