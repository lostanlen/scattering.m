function [total_ellp_norm, ellp_norms] = sc_norm(S, p)
if nargin<2
    p = 2;
end
nLayers = length(S);
powered_ellp_norms = zeros(1,nLayers);

switch p
    case 1
        norm_handle = @abs;
    case 2
        % This is faster than abs(x).^2 as it involves no intermediate sqrt
        norm_handle = @(x) real(x).*real(x) + imag(x).*imag(x);
    otherwise
        norm_handle = @(x) pow(abs(x),p);
end

for layer_index = 0:(nLayers-1)
    powered_ellp_norms(1+layer_index) = ...
        powered_layer_norm(S{1+layer_index},norm_handle);
end

switch p
    case 1
        ellp_norms = powered_ellp_norms;
        total_ellp_norm = sum(powered_ellp_norms);
    case 2
        ellp_norms = sqrt(powered_ellp_norms);
        total_ellp_norm = sqrt(sum(powered_ellp_norms));
    otherwise
        ellp_norms = pow(powered_ellps_norms,1/p);
        total_ellp_norm = pow(sum(powered_ellp_norms),1/p);
end
end