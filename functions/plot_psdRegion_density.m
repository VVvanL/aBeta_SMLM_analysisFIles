function h = plot_psdRegion_density(shp, XY, xyRg, ld, roiEdges, aes)

%% normalize ROI, localizations
normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
aspect = normEdges(2) / normEdges(4); %#ok<*NASGU>
shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
XY = XY - [roiEdges(1),roiEdges(3)]; xyRg = xyRg - [roiEdges(1),roiEdges(3)];

%% plot figure with multiple axis
h = figure;       
ax = axes; hold on
scatter(ax,XY(:,1),XY(:,2),aes.sz,aes.psd(2,:),'filled','MarkerFaceAlpha',0.37);
plot(shp,'FaceColor',aes.psd(1,:),'FaceAlpha',0.55,'EdgeColor','none'); % plot psd region
axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');

ax0 = axes;    
scatter(ax0,xyRg(:,1),xyRg(:,2),aes.sz,ld,'filled','MarkerFaceAlpha',0.37);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap);    

linkaxes([ax,ax0]); ax0.Visible = 'off'; 


end