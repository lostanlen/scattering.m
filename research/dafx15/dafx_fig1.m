nOctaves = 9;
nChromas = 192;

%%
% Generate axis
axis_begin = -3.5;
axis_end = 1.5;
axis_x = [0,0];
axis_y = [axis_begin,axis_end];
axis_z = [0,0];

% Generate spiral
nPitches = nOctaves * nChromas;
spiral_r = linspace(1/nChromas,1,nPitches);
spiral_theta = 2*pi*linspace(1/nChromas,nOctaves,nPitches);
spiral_r = spiral_r(1:(end-170));
spiral_theta = spiral_theta(1:(end-170));

spiral_x = spiral_r .* sin(spiral_theta);
spiral_z = spiral_r .* cos(spiral_theta);
spiral_y = zeros(size(spiral_x));

% Generate wavelet along time
gammatone_order = 3;
bandwidth = 20;
center_frequency = 100;
sample_rate = 1000;
duration = 0.5;
amplitude_multiplier = 500;
x_begin = -3;
x_finish = -1;

nSamples = sample_rate * duration;
samples = linspace(0,duration,nSamples);
polynomial = samples.^(gammatone_order-1);
exponential = exp(-bandwidth*samples);
sine_wave = exp(1i*center_frequency*samples);
gammatone = amplitude_multiplier * polynomial .* exponential .* sine_wave;

real_wavetime_z = zeros(size(gammatone));
real_wavetime_x = real(gammatone.');
real_wavetime_y = linspace(x_begin,x_finish,nSamples);

imag_wavetime_z = zeros(size(gammatone));
imag_wavetime_x = imag(gammatone.');
imag_wavetime_y = linspace(x_begin,x_finish,nSamples);

abs_wavetime_z = zeros(size(gammatone));
abs_wavetime_x =  - abs(gammatone.');
abs_wavetime_y = linspace(x_begin,x_finish,nSamples);

% Generate wavelet along chromas
resolution = 0.25;
mother_xi = 1/2;
sigma = 2.5;
periodization_extent = 1;
chroma_theta_offset = 1/3 * pi();

original_length = nChromas;
nPeriods = 1 + periodization_extent;
periodization = periodization_extent * original_length;
mother_range_start = - original_length/2 - periodization/2;
mother_range_end = (original_length/2-1) + periodization/2;
mother_range = (mother_range_start:mother_range_end).';
range = mother_range * resolution;
numerator = - range.*range;
denominator = 2 * sigma * sigma;
ln_gaussian = numerator ./ denominator;
gaussian = exp(ln_gaussian);
wave = exp(2i*pi*mother_xi*range);
gabor = resolution * gaussian .* wave;
expanded_gabor = reshape(gabor,original_length,nPeriods);
periodized_gabor = sum(expanded_gabor,2);
gabor_DC_bias = mean(periodized_gabor);
expanded_gaussian = reshape(gaussian,original_length,nPeriods);
periodized_gaussian = sum(expanded_gaussian,2);
scaling_factor = gabor_DC_bias/mean(periodized_gaussian);
corrective_term = scaling_factor * periodized_gaussian;
periodized_morlet = periodized_gabor - corrective_term;
shifted_morlet = fftshift(periodized_morlet);
spiral_arc = 5/nChromas + linspace( ...
    (nOctaves-2)/nOctaves+1/nChromas, ...
    (nOctaves-1)/nOctaves, ...
    nChromas);
wavechroma_theta = chroma_theta_offset + 2*pi*linspace(1/nChromas,1,nChromas);
wavechroma_range = 70:130;
trimmed_morlet = shifted_morlet(wavechroma_range).';
wavechroma_theta = wavechroma_theta(wavechroma_range);

real_wavechroma_r = real(trimmed_morlet) + spiral_arc(wavechroma_range);
real_wavechroma_z = real_wavechroma_r .* cos(wavechroma_theta);
real_wavechroma_x = real_wavechroma_r .* sin(wavechroma_theta);
real_wavechroma_y = zeros(size(wavechroma_theta));

imag_wavechroma_r = imag(trimmed_morlet) + spiral_arc(wavechroma_range);
imag_wavechroma_z = imag_wavechroma_r .* cos(wavechroma_theta);
imag_wavechroma_x = imag_wavechroma_r .* sin(wavechroma_theta);
imag_wavechroma_y = zeros(size(wavechroma_theta));

abs_wavechroma_r = abs(trimmed_morlet) + spiral_arc(wavechroma_range);
abs_wavechroma_z = abs_wavechroma_r .* cos(wavechroma_theta);
abs_wavechroma_x = abs_wavechroma_r .* sin(wavechroma_theta);
abs_wavechroma_y = zeros(size(wavechroma_theta));

% Generate wavelet along octaves
gammatone_order = 3;
bandwidth = 15;
center_frequency = 30;
sample_rate = 1000;
duration = 0.5;
amplitude_multiplier = 200;
r_begin = 1 / nOctaves;
r_finish = 6 / nOctaves;
octave_theta_offset =  pi()/6;

nSamples = sample_rate * duration;
samples = linspace(0,duration,nSamples);
polynomial = samples.^(gammatone_order-1);
exponential = exp(-bandwidth*samples);
sine_wave = exp(1i*center_frequency*samples);
gammatone = amplitude_multiplier * polynomial .* exponential .* sine_wave;

waveoctave_r = linspace(r_begin,r_finish,nSamples);
waveoctave_theta = octave_theta_offset * ones(size(waveoctave_r));

real_waveoctave_x = waveoctave_r .* cos(waveoctave_theta);
real_waveoctave_z = waveoctave_r .* sin(waveoctave_theta);
real_waveoctave_y = real(gammatone);

imag_waveoctave_x = waveoctave_r .* cos(waveoctave_theta);
imag_waveoctave_z = waveoctave_r .* sin(waveoctave_theta);
imag_waveoctave_y = imag(gammatone);

abs_waveoctave_x = waveoctave_r .* cos(waveoctave_theta);
abs_waveoctave_z = waveoctave_r .* sin(waveoctave_theta);
abs_waveoctave_y = - abs(gammatone);

% Generate thick dots for partials
sphere_diameter = 0.05;
[originalsphere_x,originalsphere_y,originalsphere_z] = sphere();
sphere_x = originalsphere_x * sphere_diameter;
sphere_y = originalsphere_y * sphere_diameter;
sphere_z = originalsphere_z * sphere_diameter;
clf;
colormap rev_gray;

nPartials = 32;
f0_spiral_index = 259;

for partial_index = 1:nPartials
    spiral_index = f0_spiral_index + round(log2(partial_index)*nChromas);
    partial_x = sphere_x - spiral_x(spiral_index);
    partial_y = sphere_y - spiral_y(spiral_index);
    partial_z = sphere_z - spiral_z(spiral_index);
    partial_color = ones(size(partial_x)) * partial_index^(-0.7);
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

line(real_wavetime_x,real_wavetime_y,real_wavetime_z, ...
    'Color',color_blue,'LineWidth',linewidth);
line(imag_wavetime_x,imag_wavetime_y,imag_wavetime_z, ...
    'Color',color_green,'LineWidth',linewidth);
line(abs_wavetime_x,abs_wavetime_y,abs_wavetime_z, ...
    'Color',color_red,'LineWidth',linewidth);

line(real_wavechroma_x,real_wavechroma_y,real_wavechroma_z, ...
    'Color',color_blue,'LineWidth',linewidth);
line(imag_wavechroma_x,imag_wavechroma_y,imag_wavechroma_z, ...
    'Color',color_green,'LineWidth',linewidth);
line(abs_wavechroma_x,abs_wavechroma_y,abs_wavechroma_z, ...
    'Color',color_red,'LineWidth',linewidth);

line(real_waveoctave_x,real_waveoctave_y,real_waveoctave_z, ...
    'Color',color_blue,'LineWidth',linewidth);
line(imag_waveoctave_x,imag_waveoctave_y,imag_waveoctave_z, ...
    'Color',color_green,'LineWidth',linewidth);
line(abs_waveoctave_x,abs_waveoctave_y,abs_waveoctave_z, ...
    'Color',color_red,'LineWidth',linewidth);

line(axis_x,axis_y,axis_z,'Color','k','LineWidth',1.2);

line(spiral_x,spiral_y,spiral_z,'Color',color_gray);

%
% Export
axis off;
axis equal;
view([0 34]);
set(gcf,'WindowStyle','docked');
zoom(20)

%%
export_fig dafx_fig1.png -transparent