function scattering_norm = sc_norm(S, spatial_subscripts, layers)
nLayers = length(S);
if nargin<3
    layers = (1:nLayers);
end
if nargin<2
    spatial_subscripts = 1;
end

formatted_S = sc_format(S, spatial_subscripts, layers);

scattering_norm = sum(abs(formatted_S(:)));
end