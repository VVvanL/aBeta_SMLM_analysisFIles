% Working script for data visualizations (scatter-plots) for aBeta/PSD95 STORM data
%%
% Select experimental level folder

clearvars; % close all

ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
ch_str = {'GluA1','PSD95'};

plot_rois = {1; 1}; % {acq#; ROI#} Acquisition number refers to order sub-folder is listed in experimental directory

%% define plot aestehtics
aes = struct();
aes.sz = 17;

aes.psd = hex2rgb(['#969696';'#737373']); % from 7-class greys, 9-class BuPu [psd_region; extra_psdXY]
aes.clus = rgb('Orange');
aes.hdr = hex2rgb('#3690c0'); % from 9-class PuBu
aes.xy = hex2rgb('#6baed6');
aes.cmap = [rgb('MidnightBlue');rgb('CornflowerBlue');rgb('SkyBlue');...
    rgb('Gold');rgb('DarkOrange');rgb('OrangeRed');rgb('Red');rgb('DarkRed')]; % colormap for plotting PSD
aes.cmap0 = [rgb('MidnightBlue'); rgb('SkyBlue'); rgb('Gold')]; % colormap for non-hdr localizations
aes.cmap1 = [rgb('OrangeRed');rgb('Red');rgb('DarkRed')]; % colormap for hdr localizations
aes.cbc = hex2rgb(['#c6dbef';'#9ecae1';'#6baed6';'#3182bd';'#08519c']); % fromn 9-class Blues

%% select parent directory (experiment-level)
folderN = uigetdir; folderN = [folderN,filesep];
foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts;
sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);
acq_n = size(plot_rois,2);
for s = 1:acq_n
    acq = plot_rois{1,s};
    subname = sublist(acq).name; subpath = fullfile(sublist(acq).folder,subname,filesep);
    smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
    hdrdir = [subpath,subname,'_hdrSummary',filesep];
    if ~exist(hdrdir,'dir'); mkdir(hdrdir); end
    
    roinames = fieldnames(roiData.ch1);
    for roi = [plot_rois{2,s}]
        r_fld = roinames{roi}; titleroot = [subname,'_',roinames{roi}];
        roiEdges = roiData.ch1.(roinames{roi}).roiEdges_nm;
        figdir = [hdrdir,titleroot,'_hdrFigures',filesep];
        if ~exist(figdir,'dir'); mkdir(figdir); end
        
        psd = roiData.(p_fld).(r_fld).synRegion.regions.shp; % PSD region
        psd_xy = roiData.(p_fld).(r_fld).localizations(:,2:3); % all PSD95 localizations
        psd_xyRg = roiData.(p_fld).(r_fld).synRegion.xy; % PSD region localizations
        psd_ld = roiData.(p_fld).(r_fld).synRegion.ld; % local density for PSD region        
               
        h1 = plot_psdRegion_density(psd, psd_xy, psd_xyRg, psd_ld, roiEdges, aes);
        % TODO: add colorbar
        title(h1.Children(2),[titleroot,' ',ch_str{2}],'Interpreter','none','FontSize',13) 
        savefig(h1,[figdir,titleroot,'_',ch_str{2},'.fig']); saveas(h1,[figdir,titleroot,'_',ch_str{2},'.png'])
        close()
        
        hdr = roiData.(h_fld).(r_fld).nanocluster.regions.shp;        
        
        xy = roiData.(h_fld).(r_fld).localizations(:,2:3); % all aBeta localizations
        xy_n0 = roiData.(h_fld).(r_fld).nanocluster.n0.xy; % non-hdr aBeta localizations
        ld_n0 = roiData.(h_fld).(r_fld).nanocluster.n0.ld;
        xy_n1 = roiData.(h_fld).(r_fld).nanocluster.n1.xy;
        ld_n1 = roiData.(h_fld).(r_fld).nanocluster.n1.ld;       
        
        h2 = plot_hdr_density(hdr, xy, xy_n0, xy_n1, ld_n0, ld_n1, roiEdges, aes);
        % TODO: add colorbar
        title(h2.Children(3),[titleroot,' ',ch_str{1}],'Interpreter','none','FontSize',13) 
        savefig(h2,[figdir,titleroot,'_',ch_str{1},'.fig']); saveas(h2,[figdir,titleroot,'_',ch_str{1},'.png'])
        close()
        
        % hdr_xy = roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_xy(2,:); hdr_xy = cell2mat(hdr_xy');        
        hdr_n = roiData.(h_fld).(r_fld).nanocluster.regions.region_n;
        center_hdr = zeros(hdr_n,2);
        for h = 1:hdr_n
                obj_xy = roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_xy{2,h}; % get xy coordinates for rHDR object
                center_hdr(h,:) = mean(obj_xy);                              
        end % hdr loop
                
        h3 = plot_hdr_over_psd(psd, hdr, xy, xy_n0, xy_n1, ld_n0, ld_n1, roiEdges, aes);
        title(h3.Children(3),[titleroot,' ',ch_str{1},'-',ch_str{2}],'Interpreter','none','FontSize',13) 
        savefig(h3,[figdir,titleroot,'_',ch_str{1},'_overPSD.fig']); 
        saveas(h3,[figdir,titleroot,'_',ch_str{1},'_overPSD.png'])
        close()
    end % ROI loop
        
end