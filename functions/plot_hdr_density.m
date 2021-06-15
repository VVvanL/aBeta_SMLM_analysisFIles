function h = plot_hdr_density(shp, XY, XYn0, XYn1, ldn0, ldn1, roiEdges, aes)
%h2 = plot_hdr_density(hdr, xy, xy_n0, xy_n1, ld_n0, ld_n1, roiEdges, aes);

%% normalize ROI, localizations
normEdges = roiEdges - [roiEdges(1),roiEdges(1),roiEdges(3),roiEdges(3)];
aspect = normEdges(2) / normEdges(4); %#ok<*NASGU>
shp.Points = shp.Points - [roiEdges(1),roiEdges(3)];
XY = XY - [roiEdges(1),roiEdges(3)];
XYn0 = XYn0 - [roiEdges(1),roiEdges(3)]; XYn1 = XYn1 - [roiEdges(1),roiEdges(3)];

%% plot figure with multiple axis
h = figure;       
ax = axes; hold on
scatter(ax,XY(:,1),XY(:,2),aes.sz,aes.psd(2,:),'filled','MarkerFaceAlpha',0.31);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); xlabel('x(nm)'); ylabel('y(nm)');

ax0 = axes;    
scatter(ax0,XYn0(:,1),XYn0(:,2),aes.sz,ldn0,'filled','MarkerFaceAlpha',0.43);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax0,aes.cmap0);

ax1 = axes;  hold on
scatter(ax1,XYn1(:,1),XYn1(:,2),aes.sz,ldn1,'filled','MarkerFaceAlpha',0.63);
axis ij; axis(normEdges); pbaspect([aspect 1 1]); colormap(ax1,aes.cmap1);

linkaxes([ax,ax0,ax1]); ax0.Visible = 'off'; ax1.Visible = 'off';

end