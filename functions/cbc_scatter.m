function [t,ax] = cbc_scatter(XY,C,roiEdges,sz,cmap,syn_regions,clr,titlestr,titleroot,lgd)    
    
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);
    set(0,'DefaultTextInterpreter','none')
    
    figure;
    t = tiledlayout(1,2); ax = struct();
    for c = 1:2
        s2 = ['ch',num2str(c)]; ax.(s2) = nexttile;
        xy = XY{c} - [roiEdges(1),roiEdges(3)];  
        shp = syn_regions.(s2);

        shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
        plot(shp,'FaceColor',clr,'FaceAlpha',0.23,'EdgeColor','none'); hold on

        scatter(xy(:,1),xy(:,2),sz,C{c},'filled','MarkerFaceAlpha',0.79);
        axis ij; axis(normEdges); pbaspect([aspect 1 1])
        colorbar; grid on
    end
    
    for c = 1:2
        s2 = ['ch',num2str(c)]; truncstr = titlestr{c}(5:end);
        colormap(ax.(s2),cmap{c}); 
        ax.(s2).Title.String = truncstr;
    end    
    t.YLabel.String = 'Y (nm)'; t.XLabel.String = 'X (nm)'; title(t,{titleroot;lgd},'Interpreter','none');    
    % cb2 = t.Children(1); cb2.Label.String = 'cbc rank';
end