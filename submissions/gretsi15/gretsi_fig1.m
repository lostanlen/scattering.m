% Reproduit la figure 1 de la soumission au GRETSI 2015
% Vincent Lostanlen, Stéphane Mallat.
% "Transformée de scattering en spirale temps-chroma-octave"

%% Loading of target waveform
signal = audioread_compat('lion.wav');

%% Creation of filter banks
% Options for scalogram
opts{1}.time.size = length(signal);
opts{1}.time.U_log2_oversampling = Inf;
opts{1}.time.nFilters_per_octave = 16;
opts{1}.time.T = 256;
opts{1}.time.max_scale = 1024;
archs = sc_setup(opts);
archs{1}.banks{1}.behavior.U.is_blurred = false;

%% Computation of wavelet modulus
[~,U] = sc_propagate(signal,archs);

%% Scalogram extraction
downsampling = 64; % the lower, the more spirals in the spiralogram
full_scalogram = transpose([U{1+1}.data{:}]);
% trim silence at last quarter
trimmed_scalogram = full_scalogram(:,1:(3/4*end));
scalogram = trimmed_scalogram(:,1:downsampling:end);

%% Scalogram display
figure(1);
hot_colormap = hot;
reverse_hot = hot_colormap(end:-1:1,:);
imagesc(scalogram);
colormap(reverse_hot);
axis off;
drawnow;

%% Computation of 3d coordinates of vertices in spiralogram
normalized_section = 4;

[full_nPitches,nSamples] = size(scalogram);
nOrientations = archs{1}.banks{1}.spec.nFilters_per_octave;
nOctaves = floor(full_nPitches/nOrientations);
nPitches = nOrientations * nOctaves;
pitch_start = full_nPitches - nPitches + 1;
max_value = max(max(scalogram));

last_orientation = (nOrientations-1) / nOrientations;
r_linspaced = linspace(0,last_orientation,nOrientations).';
r_vertices = bsxfun(@plus,r_linspaced,0:nOctaves+1);
r_vertices = r_vertices / max(max(r_vertices));
theta_vertices = linspace(0,2*pi*last_orientation,nOrientations).';
x_vertices_matrix = bsxfun(@times,r_vertices,cos(theta_vertices));
y_vertices_matrix = bsxfun(@times,r_vertices,sin(theta_vertices));
vertices = cat(3,x_vertices_matrix,y_vertices_matrix);
vertices = permute(vertices,[3 1 2]);

%% Spiralogram rendering : takes about 2 minutes
samples = linspace(0,normalized_section,nSamples);

close all;
figure(2);
color_map = reverse_hot;
hold on;
for sample_index = 1:nSamples-1
    fprintf('sample #%d/%d\n',sample_index,nSamples-1);
    sample = samples(sample_index);
    next_sample = samples(sample_index+1);
    pitch_vector = scalogram(pitch_start:end,sample_index);
    normalized_values = pitch_vector / max_value;
    alpha_values = normalized_values;
    quantized_values = ceil(64 * normalized_values);
    color_matrix = color_map(quantized_values,:);
    for octave_index = 1:nOctaves
        for orientation_index = 1:nOrientations
            % computation of color and transparencies (alphas)
            pitch_index = (octave_index-1)*nOrientations + orientation_index;
            % constant J slice
            rectangle_vertices = zeros(3,4);
            rectangle_vertices(3,:) = [sample next_sample next_sample sample];
            rectangle_vertices(1:2,1) = vertices(:,orientation_index,octave_index);
            rectangle_vertices(1:2,2) = vertices(:,orientation_index,octave_index);
            if orientation_index<nOrientations
                rectangle_vertices(1:2,3) = ...
                    vertices(:,orientation_index+1,octave_index);
                rectangle_vertices(1:2,4) = ...
                    vertices(:,orientation_index+1,octave_index);
            else
                rectangle_vertices(1:2,3) = vertices(:,1,octave_index+1);
                rectangle_vertices(1:2,4) = vertices(:,1,octave_index+1);
            end
            rectangle_color = color_matrix(pitch_index,:);
            rectangle_alpha = alpha_values(pitch_index);
            fill3( ...
                rectangle_vertices(1,:), ....
                rectangle_vertices(2,:), ...
                rectangle_vertices(3,:), ...
                rectangle_color, ...
                'FaceAlpha',rectangle_alpha, ...
                'EdgeColor','none');
            % constant T slice
            rectangle_vertices = zeros(3,4);
            rectangle_vertices(3,:) = sample * ones(1,4);
            rectangle_vertices(1:2,1) = vertices(:,orientation_index,octave_index);
            rectangle_vertices(1:2,2) = vertices(:,orientation_index,octave_index+1);
            if orientation_index<nOrientations
                rectangle_vertices(1:2,3) = ...
                    vertices(:,orientation_index+1,octave_index+1);
                rectangle_vertices(1:2,4) = ...
                    vertices(:,orientation_index+1,octave_index);
            else
                rectangle_vertices(1:2,3) = vertices(:,1,octave_index+2);
                rectangle_vertices(1:2,4) = vertices(:,1,octave_index+1);
            end
            fill3( ...
                rectangle_vertices(1,:), ....
                rectangle_vertices(2,:), ...
                rectangle_vertices(3,:), ...
                rectangle_color, ...
                'FaceAlpha',rectangle_alpha, ...
                'EdgeColor','none');
            % constant theta slice
            rectangle_vertices = zeros(3,4);
            rectangle_vertices(3,:) = [sample next_sample next_sample sample];
            rectangle_vertices(1:2,1) = vertices(:,orientation_index,octave_index);
            rectangle_vertices(1:2,2) = vertices(:,orientation_index,octave_index);
            rectangle_vertices(1:2,1) = vertices(:,orientation_index,octave_index+1);
            rectangle_vertices(1:2,2) = vertices(:,orientation_index,octave_index+1);
            fill3( ...
                rectangle_vertices(1,:), ....
                rectangle_vertices(2,:), ...
                rectangle_vertices(3,:), ...
                rectangle_color, ...
                'FaceAlpha',rectangle_alpha, ...
                'EdgeColor','none');
        end
    end
end
hold off;
axis off;
axis equal;
azimuth = 90;
elevation = 10;
line([0,0],[0,0],[0.5,4.5],'LineWidth',1.5,'Color','k')
view([azimuth,elevation]);