function h = plot_hdr_over_psd(shp_p, shp_h, XY, XYn0, XYn1, ldn0, ldn1, roiEdges, aes)

%% normalize ROI, localizations
normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
aspect = normEdges(2) / normEdges(4); %#ok<*NASGU>
% normalize shapes for psd and HDregions
shp_p.Points = shp_p.Points - [roiEdges(1),roiEdges(3)]; shp_h.Points = shp_h.Points - [roiEdges(1),roiEdges(3)];
XY = XY - [roiEdges(1),roiEdges(3)];
XYn0 = XYn0 - [roiEdges(1),roiEdges(3)]; XYn1 = XYn1 - [roiEdges(1),roiEdges(3)];

h = figure;
ax = axes; hold on
plot(shp_p,'FaceColor',aes.psd(1,:),'FaceAlpha',0.55,'EdgeColor','none'); % plot psd region
scatter(ax,XY(:,1),XY(:,2),aes.sz,aes.psd(2,:),'filled','MarkerFaceAlpha',0.17);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');

ax0 = axes;    
scatter(ax0,XYn0(:,1),XYn0(:,2),aes.sz,ldn0,'filled','MarkerFaceAlpha',0.23);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap0);

ax1 = axes;  hold on
plot(shp_h,'FaceColor',aes.clus,'FaceAlpha',0.76,'EdgeColor','none');
scatter(ax1,XYn1(:,1),XYn1(:,2),aes.sz,ldn1,'filled','MarkerFaceAlpha',0.50);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax1,aes.cmap1);

linkaxes([ax,ax0,ax1]); ax0.Visible = 'off'; ax1.Visible = 'off';


end