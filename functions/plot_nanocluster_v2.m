function h = plot_nanocluster_v2(xy, shp, xy_n0,xy_n1,ld0,ld1,nr, roiEdges,aes) %#ok<*INUSD,*INUSL>

    %% normalize ROI, localizations
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4); %#ok<*NASGU>
    xy = xy - [roiEdges(1),roiEdges(3)]; shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
    xy_n0 = xy_n0 - [roiEdges(1),roiEdges(3)]; xy_n1 = xy_n1 - [roiEdges(1),roiEdges(3)];
    nr.Points = nr.Points - [roiEdges(1),roiEdges(3)];
    
    h = figure;       
    ax = axes; hold on
    scatter(ax,xy(:,1),xy(:,2),aes.sz,'k','filled','MarkerFaceAlpha',0.23);
    plot(shp,'FaceColor',aes.psd(1,:),'FaceAlpha',0.55,'EdgeColor','none'); % plot psd region
    
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');
        
    ax0 = axes;    
    scatter(ax0,xy_n0(:,1),xy_n0(:,2),aes.sz,ld0,'filled','MarkerFaceAlpha',0.37);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap0);    
    
    ax1 = axes;  hold on
    plot(nr,'FaceColor',aes.clus,'FaceAlpha',0.69,'EdgeColor','none');
    scatter(ax1,xy_n1(:,1),xy_n1(:,2),aes.sz,ld1,'filled','MarkerFaceAlpha',0.63);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax1,aes.cmap1);
    
    linkaxes([ax,ax0,ax1]); ax0.Visible = 'off'; ax1.Visible = 'off'; 
    
    % cb0 = colorbar(ax0,'Position',[.80 .11 0.029 .815]); cb0.Label.String = 'synaptic LD';
    % cb1 = colorbar(ax1,'Position',[.90 .11 0.029 .815]); cb1.Label.String = 'nanocluster LD';    
   
end