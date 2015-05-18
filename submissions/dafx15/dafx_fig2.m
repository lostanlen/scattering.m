%% Generate Shepard-Risset glissando
sample_rate = 44100;
f0 = 20; % "fundamental" frequency, in Hz
nPartials = 10;
N = 65536; % number of samples
glissando_period = N / sample_rate; % in seconds

time_samples = linspace(0,(N-1)/sample_rate,N).';
tau = glissando_period/log(2) * pow2(time_samples/glissando_period);
partial_indices = 0:(nPartials-1);
phase_matrix = bsxfun(@times,2.^partial_indices,tau);
partials = sin(2*pi*f0*phase_matrix);
shepardrisset_glissando = sum(partial_indices,2);

%% Build scattering "architectures", i.e. filter banks and nonlinearities
opts{1}.time.size = N;
opts{1}.time.T = 2^10;
opts{1}.time.max_scale = 16*opts{1}.time.T;
opts{1}.time.nFilters_per_octave = 16;

% Options for scattering along time
opts{2}.time.handle = @morlet_1d;
opts{2}.time.max_scale = Inf;
opts{2}.time.U_log2_oversampling = 2;

% Options for scattering along chromas
opts{2}.gamma.invariance = 'bypassed';
opts{2}.gamma.U_log2_oversampling = Inf;

% Options for scattering along octaves
opts{2}.j.invariance = 'bypassed';
opts{2}.j.T = 4;
opts{2}.j.handle = @morlet_1d;
opts{2}.j.mother_xi = 0.4;
opts{2}.j.cutoff_in_dB = 5;
% Build scattering "architectures", i.e. filter banks and nonlinearities
archs = sc_setup(opts);

%% Compute spiral scattering transform of signal
[S,U,Y] = sc_propagate(shepardrisset_glissando,archs);

%%
t = 32768;
j1 = 4;
chroma1 = 8;
gamma2 = 9;

% psi-psi case
psipsi_data = U{1+2}{1,1,1}.data{gamma2};
psipsi_level1_ranges = U{1+2}{1,1,1}.ranges{1+1}{gamma2};
psipsi_level0_ranges = U{1+2}{1,1,1}.ranges{1+0}{gamma2};

gammachroma_range = collect_range(psipsi_level1_ranges(:,1));
gammaheight_range = collect_range(psipsi_level1_ranges(:,2));
width_offset = length(gammachroma_range);
height_offset = length(gammaheight_range);
portrait_width = 2 * width_offset + 1;
portrait_height = 2 * height_offset + 1;
portrait = zeros(portrait_height,portrait_width);

for gammachroma_index = 1:width_offset
    for gammaheight_index = 1:height_offset
        tensor = psipsi_data{gammachroma_index,gammaheight_index};
        ranges = psipsi_level0_ranges{gammachroma_index,gammaheight_index};
        time_index = 1 + floor((t-ranges(1,1)) / ranges(2,1));
        chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
        octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
        
        gamma_width = gammachroma_index;
        gamma_height = gammaheight_index;
        portrait(gamma_height,gamma_width) = ...
            tensor(time_index,chroma_index,octave_index,1,1);
        
        gamma_width = portrait_width - gammachroma_index + 1;
        gamma_height = gammaheight_index;
        portrait(gamma_height,gamma_width) = ...
            tensor(time_index,chroma_index,octave_index,2,1);
        
        gamma_width = gammachroma_index;
        gamma_height = portrait_height - gammaheight_index + 1;
        portrait(gamma_height,gamma_width) = ...
            tensor(time_index,chroma_index,octave_index,1,2);
        
        gamma_width = portrait_width - gammachroma_index + 1;
        gamma_height = portrait_height - gammaheight_index + 1;
        portrait(gamma_height,gamma_width) = ...
            tensor(time_index,chroma_index,octave_index,2,2);
    end
end

% psi-phi case
psiphi_data = U{1+2}{1,1,2}.data{gamma2};
psiphi_level1_ranges = U{1+2}{1,1,2}.ranges{1+1}{gamma2};
psiphi_level0_ranges = U{1+2}{1,1,2}.ranges{1+0}{gamma2};

for gammachroma_index = 1:width_offset
    tensor = psipsi_data{gammachroma_index};
    ranges = psiphi_level0_ranges{gammachroma_index};
    time_index = 1 + floor((t-ranges(1,1)) / ranges(2,1));
    chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
    octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
    
    gamma_height = 1 + height_offset;
    gamma_width = gammachroma_index;
    multiplier = prod(ranges(ranges(2,2:end)));
    portrait(gamma_height,gamma_width) = multiplier * ...
        tensor(time_index,chroma_index,octave_index,1,1);
    gamma_width = portrait_width - gammachroma_index + 1;
    portrait(gamma_height,gamma_width) = multiplier * ...
        tensor(time_index,chroma_index,octave_index,2,1);
end

% phi-psi case
phipsi_data = U{1+2}{1,2,1}.data{gamma2};
phipsi_level1_ranges = U{1+2}{1,2,1}.ranges{1+1}{gamma2};
phipsi_level0_ranges = U{1+2}{1,2,1}.ranges{1+0}{gamma2};

for gammaheight_index = 1:height_offset
    tensor = phipsi_data{gammaheight_index};
    ranges = phipsi_level0_ranges{gammaheight_index};
    time_index = 1 + floor((t-ranges(1,1)) / ranges(2,1));
    chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
    octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
    
    gamma_width = 1 + width_offset;
    gamma_height = gammaheight_index;
    multiplier = prod(ranges(2,2:end));
    portrait(gamma_height,gamma_width) = multiplier * ...
        tensor(time_index,chroma_index,octave_index,1,1);
    
    gamma_height = portrait_height - gammaheight_index + 1;
    portrait(gamma_height,gamma_width) = multiplier * ...
        tensor(time_index,chroma_index,octave_index,2,1);
end


% phi-phi case
phiphi_data = U{1+2}{1,2,2}.data{gamma2};
ranges = U{1+2}{1,2,2}.ranges{1+0}{gamma2};
time_index = 1 + floor((t-ranges(1,1))/ranges(2,1));
chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
multiplier = prod(ranges(2,2:end));
portrait(1+height_offset,1+width_offset) = multiplier * ...
    phiphi_data(time_index,chroma_index,octave_index);

%% Export
colormap rev_gray;
imagesc(portrait);
axis off
export_fig dafx_fig2.png -transparent