function h = plot_cbc_hdr(xy, psd, hdr, cbc, aes, roiEdges)
    
    h = figure; hold on;
    % normalize roi edges
    normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
    aspect = normEdges(2) / normEdges(4);    
    
    % plot normalized psd(synaptic) region     
    for p = 1:2        
        psd{p}.Points = psd{p}.Points - [roiEdges(1),roiEdges(3)];
        plot(psd{p},'FaceColor',aes.psd(p,:),'FaceAlpha',0.55,'EdgeColor','none');
    end
    
    hdr.Points = hdr.Points - [roiEdges(1),roiEdges(3)];
    plot(hdr,'FaceColor',aes.hdr,'FaceAlpha',0.61,'EdgeColor','none');
        
    xy = xy - [roiEdges(1),roiEdges(3)];
    scatter(xy(:,1),xy(:,2), aes.sz, cbc,'filled','MarkerFaceAlpha',0.55); colormap(aes.cbc) 

   axis ij; axis(normEdges); xlabel('x(nm)'); ylabel('y(nm)'); pbaspect([aspect 1 1])
    

end