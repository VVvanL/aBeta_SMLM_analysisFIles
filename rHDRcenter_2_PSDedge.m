% working script to determine distance from rHDR center to edge of PSD region

clearvars; % close all
%=============
multi = 1; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
% ch_str = {'GluA1','PSD95'};
% ratio_cutoff = 0.30; % minor/major axis ratio of PSD region to exclude orthogananl viewed synapses
% TODO: set switch block for above exclusion

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = [];
    dir_n = size(dirlist,1); folderP = [folderP,filesep];    
else
    folderN = uigetdir; folderN = [folderN,filesep];
    dir_n = 1;
end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);
    load([folderN,dirname,'_hdrData.mat'],'hdr_data')
    
    hdr_dist = struct();    
    hdr_dist.D = [];
    hdr_dist.center_hdr = [];
   
    for s = 1:sub_n
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);
        % roi = find(roiData.axis_ratios(:,2) > ratio_cutoff)'; % only loop through non-orthogonal PSDs
        roi = find(~isnan(roiData.synRegions{1,1}(:,1)) & ~isnan(roiData.synRegions{1,2}(:,1)))';
        hdrdir = [subpath,subname,'_hdrSummary',filesep];
        if ~exist(hdrdir,'dir'); mkdir(hdrdir); end        
        
        for roi = roi
            r_fld = roinames{roi}; titleroot = [subname,'_',roinames{roi}];
            roi_padded = ['roi',num2str(roi,'%02.f')];
            if ~isfield(roiData.(h_fld).(r_fld),'nanocluster') || ...
                    ~isfield(roiData.(h_fld).(r_fld).nanocluster.regions,'region_n')
            continue
            end
            hdr_n = size(roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_xy,2);
            psd = roiData.(p_fld).(r_fld).synRegion.regions.shp; % get alphaShape for PSD region(s)
            D = zeros(hdr_n,1); center_hdr = zeros(hdr_n,2);
            for h = 1:hdr_n
                hdr_xy = roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_xy{2,h}; % get xy coordinates for rHDR object
                center_hdr(h,:) = mean(hdr_xy);
                if ~inShape(psd,center_hdr(h,:)) % determine if center lies within psd boundary
                    [~,D(h)] = nearestNeighbor(psd,center_hdr(h,:));                
                end               
            end % hdr loop (per-object in ROI)
            hdr_dist.D = vertcat(hdr_dist.D, D);
            hdr_dist.center_hdr = vertcat(hdr_dist.center_hdr, center_hdr);
        end % roi loop    
        
    end % subdirectory loop (acquisition-level)
    
    hdr_data.center_hdr = hdr_dist.center_hdr;
    hdr_data.dist_psdEdge = hdr_dist.D;
    save([folderN,dirname,'_hdrData.mat'],'hdr_data','-append')
    
end % directory loop (experiment-level)