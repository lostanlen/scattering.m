%% Generate Shepard-Risset glissando
sample_rate = 44100;
f0 = 20; % "fundamental" frequency, in Hz
nPartials = 10;
N = 65536; % number of samples
glissando_period = N / sample_rate; % in seconds

time_samples = linspace(0,(N-1)/sample_rate,N).';
tau = glissando_period/log(2) * pow2(time_samples/glissando_period);
partials = 0:(nPartials-1);
operand_matrix = bsxfun(@times,2.^partials,tau);
partials = sin(2*pi*f0*operand_matrix);
shepardrisset_glissando = sum(partials,2);

%% Build scattering "architectures", i.e. filter banks and nonlinearities
opts{1}.time.size = N;
opts{1}.time.T = 2^10;
opts{1}.time.max_scale = 4*opts{1}.time.T;
opts{1}.time.nFilters_per_octave = 16;
 
% Options for scattering along time
opts{2}.time.max_scale = Inf;
opts{2}.time.U_log2_oversampling = 2;

% Options for scattering along chromas
opts{2}.gamma.invariance = 'bypassed';
opts{2}.gamma.U_log2_oversampling = Inf;

% Options for scattering along octaves
opts{2}.j.invariance = 'bypassed';

% Build scattering "architectures", i.e. filter banks and nonlinearities
archs = sc_setup(opts);

%% Compute spiral scattering transform of signal
[S,U,Y] = sc_propagate(shepardrisset_glissando,archs);