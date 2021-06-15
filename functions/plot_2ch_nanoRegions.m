function h =  plot_2ch_nanoRegions(XYn0, XYn1, XYnr, LDn0, LDn1, LDnr, nano, psd, aes, roiEdges)   %#ok<INUSL>
    %h = plot_2ch_nanoRegions(XYnr, LDnr, aes.cmap_2nr, psd, aes.clr_syn{3}, aes.sz, roiEdges, titleroot);
    
    % normalize datapoints
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);
    
    psd.Points = psd.Points - [roiEdges(1),roiEdges(3)];
        
    for c = 1:2
        nano{c}.Points = nano{c}.Points - [roiEdges(1),roiEdges(3)]; 
        XYnr{c} = XYnr{c} - [roiEdges(1),roiEdges(3)];
        XYn0{c} = XYn0{c} - [roiEdges(1),roiEdges(3)]; XYn1{c} = XYn1{c} - [roiEdges(1),roiEdges(3)];
    end    
    
    h = figure; % hold on; grid on
    
    % plot normalized psd(synaptic) region
    ax = axes; hold on %#ok<*NASGU>
    xy = XYnr{2};
    
    plot(psd,'FaceColor',aes.clr_syn{3},'FaceAlpha',0.19,'EdgeColor','none');
    % plot nanoregion boundaries for PSD/geph   
    plot(nano{2},'FaceColor',aes.clr_syn{2}, 'FaceAlpha',0.42, 'EdgeColor','none');
    
    % scatter(xy(:,1),xy(:,2), aes.sz, aes.clr_syn{c},'filled','MarkerFaceAlpha',0.63);
    axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
    
    %%  plot receptor-localizations with density-based colormap
    % plot non-nanclustered points
    ax0 = axes; % axis for non-clustered points
    xy = XYn0{1}; ld = LDn0{1};
    
    scatter(ax0, xy(:,1),xy(:,2),aes.sz,ld,'filled','MarkerFaceAlpha',0.70);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap0);
    
    % plot nano-clustered points
    ax1 = axes;  hold on
    xy = XYn1{1}; ld = LDn1{1};
    
    plot(nano{1},'FaceColor',aes.clr_syn{4},'FaceAlpha',0.57,'EdgeColor','none');
    scatter(ax1, xy(:,1),xy(:,2), aes.sz, ld,'filled','MarkerFaceAlpha',0.79);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax1,aes.cmap1);
    
    linkaxes([ax,ax0,ax1]); ax0.Visible = 'off'; ax1.Visible = 'off';

    
    % title([titlestr,'_nanoRegions'],'Interpreter','none')
    
end