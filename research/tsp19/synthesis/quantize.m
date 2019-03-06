% QUANTIZE Quantize array into a number of bins
%
% Usage
%   y = QUANTIZE(x, bins, scaling);
%
% Input
%   x: The array to be quantized.
%   bins: The number of bins to use (default 256).
%   scaling: One of 'linear' (default) or 'logarithmic'.
%
% Output
%   y: The array x, but with each value mapped into its corresponding bin.
%      These bins are uniformly spaced between the minimum and maximum values
%      of x.

function y = quantize(x, bins, scaling)
    if nargin < 2 || isempty(bins)
        bins = 256;
    end

    if nargin < 3 || isempty(scaling)
        scaling = 'linear';
    end

    mn = min(x(:));
    mx = max(x(:));

    x = (x - mn)/(mx-mn);

    if strcmp(scaling, 'linear')
        y = round(x*(bins-1))/(bins-1);
    elseif strcmp(scaling, 'logarithmic')
        x = log2(x + 1);

        y = round(x*(bins-1))/(bins-1);

        y = 2.^y - 1;
    else
        error('The ''scaling'' argument must be ''linear'' or ''logarithmic''');
    end

    y = mn + y*(mx - mn);
end
