function rev_gray_colormap = rev_gray()
gray_colormap = gray();
rev_gray_colormap = gray_colormap(end:-1:1,:);
end

