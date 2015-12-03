nOctaves = 9;
nChromas = 192;

% Generate spiral
nPitches = nOctaves * nChromas;
spiral_r = linspace(1/nChromas,1,nPitches);
spiral_theta = 2*pi*linspace(1/nChromas,nOctaves,nPitches);
spiral_r = spiral_r(1:(end-170));
spiral_theta = spiral_theta(1:(end-170));

spiral_x = spiral_r .* sin(spiral_theta);
spiral_z = spiral_r .* cos(spiral_theta);
spiral_y = zeros(size(spiral_x));

% Generate thick dots for partials
sphere_diameter = 0.05;
[originalsphere_x,originalsphere_y,originalsphere_z] = sphere();
sphere_x = originalsphere_x * sphere_diameter;
sphere_y = originalsphere_y * sphere_diameter;
sphere_z = originalsphere_z * sphere_diameter;
clf;
colormap rev_gray;

nPartials = 32;
f0_spiral_index = 208;

for partial_index = 1:nPartials
    spiral_index = f0_spiral_index + round(log2(partial_index)*nChromas);
    partial_x = sphere_x - spiral_x(spiral_index);
    partial_y = sphere_y - spiral_y(spiral_index);
    partial_z = sphere_z - spiral_z(spiral_index);
    partial_color = ones(size(partial_x)) / sqrt(partial_index);
    hold on;
    surf(partial_x,partial_y,partial_z,partial_color,'LineStyle','none');
    hold off;
end
set(gca,'CLim',[0 1]);
axis off;
axis equal;

% Render all curves
color_blue = [0,87,231]/255;
color_green = [0,135,68]/255;
color_red = [214,45,32]/255;
color_gray = 0.7 * [1,1,1];

linewidth = 1.2;

line(spiral_x,spiral_y,spiral_z,'Color',color_gray);

%
% Export
axis off;
axis equal;
view(0,0);

%%
export_fig dafx_presentation.png -transparent