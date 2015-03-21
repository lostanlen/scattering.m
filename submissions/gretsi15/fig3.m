N = 16384;

% Options for scalogram
opts{1}.time.size = N;
opts{1}.time.U.log2_oversampling = 2;
opts{1}.time.max_Q = 16;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 4096;
opts{1}.nonlinearity.name = 'modulus';

% Options for scattering along time
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.max_scale = Inf;
opts{2}.time.max_Q = 1;
opts{2}.time.U_log2_oversampling = 2;

% Options for scattering along chromas
opts{2}.gamma.invariance = 'bypassed';

% Options for scattering along octaves
opts{2}.j.handle = @poisson_1d;
opts{2}.j.invariance = 'bypassed';
opts{2}.j.mother_xi = 0.50;

% Build scattering "architectures", i.e. filter banks and nonlinearities
archs = setup(opts);

% Load audio file
file_path = fullfile('submissions','gretsi15','lion.wav');
signal = audioread_compat(file_path);

% Compute scattering transform of signal
[S,U,Y] = propagate(signal,archs);
 
%%
% Extract a block of second-order "spiral" coefficients
time_scale = 6;
chroma_scale = 4;
octave_scale = 2;
spiral_transform = U{1+2}{1,1,1}.data;
spiral_block = spiral_transform{time_scale}{chroma_scale,octave_scale};
sizes = size(spiral_block);
scattergram_sizes = [sizes(1),sizes(2)*sizes(3),sizes(4),sizes(5)];
scattergram = reshape(spiral_block,scattergram_sizes);
time_range = 1:size(scattergram,1);
time_range = time_range((1/8)*end:(7/8)*end);
gamma_range = 1:size(scattergram,2);
scattergram = abs(scattergram(time_range,gamma_range,:,:));
normalizer = max(max(max(scattergram(:))));
scattergram = 64 * scattergram / normalizer;
hot_colormap = hot();
reverse_hot_colormap = hot_colormap(end:-1:1,:);

%%
figure(1);
image(scattergram(:,:,1,1).');
axis off; colormap(reverse_hot_colormap);
export_fig raw_fig3a.png -transparent

%%
figure(2);
image(scattergram(:,:,1,2).');
axis off; colormap(reverse_hot_colormap);
export_fig raw_fig3b.png -transparent

%%
figure(3);
image(scattergram(:,:,2,1).');
axis off; colormap(reverse_hot_colormap);
export_fig raw_fig3c.png -transparent

%%
figure(4);
image(scattergram(:,:,2,2).');
axis off; colormap(reverse_hot_colormap);
export_fig raw_fig3d.png -transparent