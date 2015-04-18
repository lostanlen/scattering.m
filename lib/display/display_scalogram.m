function scalogram = display_scalogram(U1)
% TODO: provide multi-channel display of 1D signals
%% On-the-fly unpadding (TODO)

%% Interpolation
nSamples = length(U1.data{1});
 interpolation_handle = ...
     @(y) real(interp1(linspace(1,nSamples,length(y)),y,1:nSamples, ...
     'nearest') * length(y)/nSamples);
scalogram_cells = ...
    cellfun(interpolation_handle,U1.data,'UniformOutput',false);

%% Conversion to matrix
scalogram = cell2mat(scalogram_cells);

%% Show matrix
if nargout==0
    imagesc(scalogram);
end
end
