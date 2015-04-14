function reverse_hot_colormap = rev_hot()
hot_colormap = hot();
reverse_hot_colormap = hot_colormap(end:-1:1,:);
end