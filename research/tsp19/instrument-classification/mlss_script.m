N = 131072;
octave_bounds = [2 8];
nfo = 12;
gamma_bounds = [(octave_bounds(1)-1)*nfo octave_bounds(2)*nfo-1];

opts{1}.banks.time.nFilters_per_octave = nfo;
opts{1}.banks.time.size = N;
opts{1}.banks.time.T = N;
opts{1}.banks.is_chunked = false;
opts{1}.banks.gamma_bounds = gamma_bounds;
opts{1}.banks.wavelet_handle = @gammatone_1d;
opts{1}.invariants.time.invariance = 'summed';

archs = sc_setup(opts);

%%
dataset_path = '~/datasets/medleydb-single-instruments';
chunks = {...
    'training/00_clarinet/03_SwingJazz_S04/clarinet_SwingJazz_S04_chunk032' ; ...
    'training/01_distorted electric guitar/10_Hendrix_S03/distorted electric guitar_Hendrix_S03_chunk001' ; ...
    'training/02_female singer/05_Rockabilly_S05/female singer_Rockabilly_S05_chunk012' ; ...
    'test/03_flute/12_3786/flute_12_3786_chunk011';
    'test/04_piano/05_2987/piano_05_2987_chunk065';
    'test/05_tenor saxophone/03_2128/tenor saxophone_03_2128_chunk001';
    'training/06_trumpet/02_ModalJazz_S05/trumpet_ModalJazz_S05_chunk022';
    'test/07_violin/20_1946/violin_20_1946_chunk001'
    }
nChunks = length(chunks);
%%

waveforms = cell(1, nChunks);
scalograms = cell(1, nChunks);

for chunk_index = 1:nChunks
    chunk = chunks{chunk_index};
    path = fullfile(dataset_path, chunk); 
    chunk_waveform = audioread([path, '.wav']);
    [S,U] = sc_propagate(chunk_waveform, archs);
    waveforms{chunk_index} = chunk_waveform;
    scalograms{chunk_index} = display_scalogram(U{1+1}{1});
end

%%
chunk_index = 8;
soundsc(waveforms{chunk_index}, 44100);
%%
epsilon = 0.01;
gamma_start = 10;
gamma_stop = 105;
colormap jet;

for chunk_index = 1:nChunks
    scalogram = scalograms{chunk_index};
    scalogram = scalogram(gamma_start:gamma_stop, :);
    scalogram = log1p(0.01 * scalogram);
    subplot(4, 2, chunk_index);
    imagesc(scalogram);
    axis off
end
%%

set(gcf, 'Position', [-40 10000 1600 3000]);
export_fig -transparent medleydb_spectrograms.png

%% Export audio
for chunk_index = 1:nChunks
    waveform = waveforms{chunk_index};
    new_path = chunks{chunk_index};
    new_path = strsplit(new_path, '/');
    new_path = [new_path{2}, '.wav'];
    audiowrite(new_path, waveform, 44100);
end