function h = plot_cbc(XY, psd, nano, cbc, cc, aes, roiEdges)

    % normalize datapoints
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);
    
    psd.Points = psd.Points - [roiEdges(1),roiEdges(3)];
        
    for c = 1:2
        nano{c}.Points = nano{c}.Points - [roiEdges(1),roiEdges(3)]; 
        XY{c} = XY{c} - [roiEdges(1),roiEdges(3)];        
    end  

    h = figure;
    
    %% plot region shapes (PSD region, nano-regions)
    ax1 = axes; hold on
    plot(psd,'FaceColor',aes.clr_syn{3},'FaceAlpha',0.19,'EdgeColor','none');
    for c = 1:2
        plot(nano{c},'FaceColor',aes.clr_syn{c}, 'FaceAlpha',0.23, 'EdgeColor','none');        
    end
    axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
    
    %% plot CBC scatter plot (receptors, ch1)
    ax2 = axes;
    xy = XY{1};
    scatter(ax2, xy(:,1),xy(:,2), aes.sz, cbc{cc,1},'filled','MarkerFaceAlpha',1.0);
    axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax2,aes.cbc{1});

    linkaxes([ax1,ax2]); ax2.Visible = 'off'; 

end