multiplier = 10^3;
subfigures = {'target','mcdermott','firstorder','plain','joint4oct'};
nSubfigures = length(subfigures);
size_multiplier = 4;
for subfigure_index = 1:nSubfigures
    clf();
    colormap rev_hot;
    subfigure = subfigures{subfigure_index};
    data_path = ['accipiter_summary_',subfigure,'.mat'];
    load(data_path);
    summary_name = [subfigure,'_summary'];
    U1 = eval([summary_name,'.U{1+1}']);
    scalogram = display_scalogram(U1);
    scalogram = scalogram(:,1:32768);
    scalogram = scalogram / max(scalogram(:));
    logscalogram = log(1+multiplier*scalogram);
    imagesc(logscalogram);drawnow;
    set(gcf,'Units','centimeters');
    set(gcf,'Position',[5.0 5.0 size_multiplier*8.6 size_multiplier*2.0])
    axis off;
    subfigure_path = ['fig2',char(96+subfigure_index),'.png'];
    export_fig(subfigure_path,'-transparent');
end