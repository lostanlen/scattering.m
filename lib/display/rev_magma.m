function rev_magma_colormap = rev_magma()
    magma_colormap = magma();
    rev_magma_colormap = magma_colormap(end:-1:1, :);
end