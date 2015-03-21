N = 16384;

% Options for scalogram
opts{1}.time.size = N;
opts{1}.time.nFilters_per_octave = 16;
 
% Options for scattering along time
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.max_scale = Inf;
opts{2}.time.max_Q = 2;
opts{2}.time.U_log2_oversampling = 2;

% Options for scattering along chromas
opts{2}.gamma.invariance = 'bypassed';
opts{2}.gamma.U_log2_oversampling = Inf;

% Options for scattering along octaves
opts{2}.j.handle = @poisson_1d;
opts{2}.j.invariance = 'bypassed';
opts{2}.j.mother_xi = 0.33;
opts{2}.j.decay_factor = 1/4;

% Build scattering "architectures", i.e. filter banks and nonlinearities
archs = setup(opts);

% We start by computing an empty scalogram
signal = zeros(N,1);
U{1+0} = initialize_U(signal);
Y{1} = U_to_Y(U{1+0},archs{1});
U{1+1} = Y_to_U(Y{1}{end},archs{1});

% We put a Dirac peak
U{1+1}.data{round(end/3)}(end/2) = 1;

% We compute the spiral scattering transform
Y{2} = U_to_Y(U{1+1},archs{2});

% Options for figure rendering
hot_colormap = hot();
reverse_hot_colormap = hot_colormap(end:-1:1,:);

%% Figure 2a
spiral_scattergram = Y{2}{1+3}{1,1,1}.data{5}{1,1};
sizes = size(spiral_scattergram);
scattergram_sizes = [sizes(1),sizes(2)*sizes(3),sizes(4),sizes(5)];
spiral_scattergram = reshape(spiral_scattergram,scattergram_sizes);
gamma_range = 1:70;
spiral_scattergram = real(spiral_scattergram(:,gamma_range,:,:));
spiral_scattergram(abs(spiral_scattergram)<1e-5) = 0;
normalizer = max(abs(spiral_scattergram(:)));
spiral_scattergram = 32 + 32 * spiral_scattergram/normalizer;
colormap(reverse_hot_colormap);
image(spiral_scattergram(:,:,2,1)');
axis off;
export_fig raw_fig2a.png -transparent