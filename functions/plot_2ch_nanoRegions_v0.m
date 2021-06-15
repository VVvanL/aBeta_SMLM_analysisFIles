function h =  plot_2ch_nanoRegions(XY, LD, cmap, nano, syn, clr, sz, roiEdges, titlestr)   %#ok<INUSL>
    %h = plot_2ch_nanoRegions(XYnr, LDnr, aes.cmap_2nr, psd, aes.clr_syn{3}, aes.sz, roiEdges, titleroot);
    
    h = figure; hold on; grid on
    
    % plot normalized psd(synaptic) region
    syn.Points = syn.Points - [roiEdges(1),roiEdges(3)];
    plot(syn,'FaceColor',clr{3},'FaceAlpha',0.25,'EdgeColor','none');
    % plot nanoregion boundaries
    for c = 1:2
        nano{c}.Points = nano{c}.Points - [roiEdges(1),roiEdges(3)];
        plot(nano{c},'FaceColor',clr{c},'FaceAlpha',0.25,'EdgeColor','none');
    end
    
    % scatterplot 
    for c = 1:2
        xy = XY{c} - [roiEdges(1),roiEdges(3)]; 
        normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
        aspect = normEdges(2) / normEdges(4);
        
        scatter(xy(:,1),xy(:,2),sz,clr{c},'filled','MarkerFaceAlpha',0.75);
        axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
        % colormap(cmap{c}); colorbar        
    end  
    
    title([titlestr,'_nanoRegions'],'Interpreter','none')
    
end