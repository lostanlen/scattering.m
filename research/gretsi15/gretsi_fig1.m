% Reproduit la figure 1 de la soumission au GRETSI 2015
% Vincent Lostanlen, Stephane Mallat.
% "Transformee de scattering en spirale temps-chroma-octave"

%% Figure generation
% Settings
nPoints_per_turn = 100;
nTurns = 3.1;
radius = 0.8;
azimuth = 0;
elevation = 30;
circle_altitude = -0.3;
tick_length = 0.1;

% Spiral
nPoints = round(nPoints_per_turn * nTurns);
angle = linspace(0,2*pi*nTurns,nPoints);
spiral_x = radius * cos(angle);
spiral_y = radius * sin(angle);
spiral_z = linspace(0,nTurns,nPoints);

% Axis
axis_x = [0,0];
axis_y = [0,0];
axis_z = [circle_altitude,nTurns];

% Circle
circle_x = spiral_x;
circle_y = spiral_y;
circle_z = circle_altitude * ones(1,nPoints);

% Ticks
tick_x = [0 -tick_length*cos(azimuth)];
tick_y = [0 tick_length*sin(azimuth)];

% Rendering
clf;
line(spiral_x,spiral_y,spiral_z,'Color','k','LineWidth',2);
line(axis_x,axis_y,axis_z,'Color','k','LineWidth',5);
line(circle_x,circle_y,circle_z,'Color','k','LineWidth',5);
for turn = 1:nTurns
    tick_z = [turn,turn] - 0.5;
    line(tick_x,tick_y,tick_z,'Color','k','LineWidth',5)
end
axis off;
axis equal;
view([azimuth,elevation]);

%% Export
export_fig raw_spiral.png -transparent