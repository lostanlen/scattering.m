function shoot_spiral_video(S1,directory)
if nargin<4
    directory = 'spiral_video_frames';
end
%%
time_key.time = cell(1);
time_variable = get_leaf(S1.variable_tree,time_key);
time_subscript = time_variable.subscripts;
nTimeframes = size(S1.data,time_subscript);
gamma_key.time{1}.gamma = cell(1);
gamma_variable = get_leaf(S1.variable_tree,gamma_key);
gamma_subscript = gamma_variable.subscripts;
nPitches = size(S1.data,gamma_subscript);

value_matrix = ceil(64 * S1.data/max(S1.data(:)));
value_matrix(~value_matrix) = 1;
value_matrix = fliplr(int8(value_matrix));
color_map = rev_hot();

%%
nOrientations = gamma_variable.spec.nFilters_per_octave;
nOctaves = ceil(nPitches/nOrientations);
last_orientation = (nOrientations-1) / nOrientations;
r_linspaced = linspace(0,last_orientation,nOrientations).';
r_vertices = bsxfun(@plus,r_linspaced,0:1:(nOctaves+1));
theta_vertices = linspace(0,2*pi*last_orientation,nOrientations).';
x_vertices_matrix = bsxfun(@times,r_vertices,cos(theta_vertices));
y_vertices_matrix = bsxfun(@times,r_vertices,sin(theta_vertices));
vertices = cat(3,x_vertices_matrix,y_vertices_matrix);
vertices = permute(vertices,[3 1 2]);
orientations = 1 + mod(0:(nPitches-1),nOrientations);
octaves = floor((0:(nPitches-1))/nOrientations) + 1;
trapezoid = zeros(2,4);

%%
mkdir(directory)
nDigits = 1 + floor(log10(nTimeframes));
string_format = ['%0',num2str(nDigits),'d'];

side = nOctaves + 2;
background_x = [side,side,-side,-side];
background_y = [side,-side,-side,side];
background_color = color_map(1,:);

%%
hold on;
fill(background_x,background_y,background_color,'LineStyle','none');
axis equal;
axis off;
for time_index = 1:nTimeframes
    fprintf('Frame %d / %d\n',time_index,nTimeframes);
    for pitch = 1:nPitches
        orientation = orientations(pitch);
        octave = octaves(pitch);
        trapezoid(:,1) = vertices(:,orientation,octave);
        if orientation<nOrientations
            trapezoid(:,2) = vertices(:,orientation+1,octave);
            trapezoid(:,3) = vertices(:,orientation+1,octave+1);
        else
            trapezoid(:,2) = vertices(:,1,octave+1);
            trapezoid(:,3) = vertices(:,1,octave+2);
        end
        trapezoid(:,4) = vertices(:,orientation,octave+1);
        value = value_matrix(time_index,pitch);
        color = color_map(value,:);
        fill(trapezoid(1,:),trapezoid(2,:),color,'LineStyle','none');
    end
    framenumber_string = num2str(time_index,string_format);
    frame_path = [directory,'/frame-',framenumber_string,'.png'];
    export_fig(frame_path);
end
hold off;

end

