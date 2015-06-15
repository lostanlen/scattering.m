%% Loading of target waveform
[original_waveform,sample_rate] = audioread_compat('sequenza_at3min42.wav');
start = 5.75*2^16;
nSamples = 2^16;
signal = original_waveform((start-1) + (1:nSamples));
soundsc(signal,sample_rate);
plot(signal);

%% Creation of wavelet filterbank
opts{1}.time.size = length(signal);
opts{1}.time.U_log2_oversampling = 1;
opts{1}.time.nFilters_per_octave = 24;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 4096;

opts{2}.time.T = 32768;
opts{2}.time.U_log2_oversampling = 3;
opts{2}.time.handle = @gammatone_1d;
opts{2}.time.max_Q = 1;
opts{2}.time.max_scale = Inf;
opts{2}.time.nFilters_per_octave = 2;

opts{2}.gamma.invariance = 'bypassed';
opts{2}.gamma.U_log2_oversampling = Inf;
opts{2}.gamma.S_log2_oversampling = Inf;
opts{2}.gamma.phi_bw_multiplier = 1;

opts{2}.j.invariance = 'bypassed';
opts{2}.j.handle = @morlet_1d;
opts{2}.j.U_log2_oversampling = Inf;
opts{2}.j.S_log2_oversampling = Inf;
opts{2}.j.phi_bw_multiplier = 1;

archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

% Computation of wavelet modulus
[S,U] = sc_propagate(signal,archs);
disp('done');
%% Render scalogram
full_scalogram = display_scalogram(U{1+1});
xmin = 1;
xmax = 60000;
ymin = 30;
ymax = 182;
sub_scalogram = full_scalogram(ymin:ymax,xmin:xmax);

multiplier = 200;
log_scalogram = log1p(multiplier*sub_scalogram);

imagesc(log_scalogram);
colormap rev_hot;
axis off;

%% Export scalogram
export_fig dafx_fig4a.png -transparent

%% %%
t = 13000;
j1 = 8;
chroma1 = 5;
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
    tensor = psiphi_data{gammachroma_index};
    ranges = psiphi_level0_ranges{gammachroma_index};
    time_index = 1 + floor((t-ranges(1,1)) / ranges(2,1));
    chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
    octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
    
    gamma_height = 1 + height_offset;
    gamma_width = gammachroma_index;
    multiplier = prod(ranges(2,2:end));
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

% Render
colormap rev_hot;
imagesc(portrait);
set(gca,'YDir','normal');
axis off

%% Export
export_fig dafx_fig4b.png -transparent

%%
%% %%
t = 41000;
j1 = 5;
chroma1 = 14;
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
    tensor = psiphi_data{gammachroma_index};
    ranges = psiphi_level0_ranges{gammachroma_index};
    time_index = 1 + floor((t-ranges(1,1)) / ranges(2,1));
    chroma_index = 1 + floor((chroma1-ranges(1,2)) / ranges(2,2));
    octave_index = 1 + floor((j1-ranges(1,3)) / ranges(2,3));
    
    gamma_height = 1 + height_offset;
    gamma_width = gammachroma_index;
    multiplier = prod(ranges(2,2:end));
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

% Render
colormap rev_hot;
imagesc(portrait);
set(gca ,'YDir','normal');
axis off

%% Export
export_fig dafx_fig4c.png -transparent