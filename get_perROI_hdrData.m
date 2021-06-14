% scratch script to plot perROI data for gab/gephyrin datasets
% 210610 Updated to retrieve rHDR number per ROI
clearvars; % close all
%=============
multi = 1; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
ch_psd = 2; p_fld = ['ch',num2str(ch_psd)];
ch_hdr = 1; h_fld = ['ch',num2str(ch_hdr)];
ch_str = {'aBeta','PSD95'};

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = [];
    dir_n = size(dirlist,1); folderP = [folderP,filesep];
    load([folderP, parent_name,'_hdr_data_multi.mat'],'hdr_data_multi')
    [exp,xa,xc] = unique(hdr_data_multi.experiment);
    hdr_data_multi.perROI.experiment = {};
    hdr_data_multi.perROI.acquisition = {};
    hdr_data_multi.perROI.rHDR_n = [];
    hdr_data_multi.perROI.cbc_values = [];
    hdr_data_multi.perROI.pHDR_overlap = [];
    hdr_data_multi.perROI.psd_overlap = [];
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
    
    [acq,ia,ic] = unique(hdr_data.acquisition); roi_n = length(acq); %NOTE: ROI is total for experiment 
    rHDR_n_exp = [];
    cbc_mean_exp = [];
    pHDR_overlap_exp = [];
    psd_overlap_exp = []; 
    
    for s = 1:sub_n
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);        
        roi = find(~isnan(roiData.synRegions{1,1}(:,1)) & ~isnan(roiData.synRegions{1,2}(:,1)))';
        rHDR_n = NaN(roi_n,1);
        cbc_mean = NaN(roi_n,1);        
        pHDR_overlap = NaN(roi_n,1);
        psd_overlap = NaN(roi_n,1);    
    
        for r = roi
            r_fld = roinames{r}; titleroot = [subname,'_',roinames{r}];
            if ~isfield(roiData.(h_fld).(r_fld),'nanocluster') || ...
                    ~isfield(roiData.(h_fld).(r_fld).nanocluster.regions,'region_n') || ...
                    ~isfield(roiData.(p_fld).(r_fld).nanocluster,'regions')
            continue
            end
            
            rHDR_n(r) = roiData.(h_fld).(r_fld).nanocluster.regions.region_n;
            cbc_values = cell2mat(roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.cbc(1,:)');
            cbc_mean(r) = mean(cbc_values);        
            rHDRarea = [roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{1,:}];
            area_pHDRoverlap = ...
                [roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{2,:}] .* rHDRarea;
            area_PSDoverlap = ...
                [roiData.(h_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{3,:}] .* rHDRarea;
            pHDR_overlap(r) = sum(area_pHDRoverlap) / sum(rHDRarea);
            psd_overlap(r) = sum(area_PSDoverlap) / sum(rHDRarea);       
        end % roi-loop
    
    rHDR_n(isnan(rHDR_n)) = [];    
    cbc_mean(isnan(cbc_mean)) = [];    
    pHDR_overlap(isnan(pHDR_overlap)) = [];
    psd_overlap(isnan(psd_overlap)) = [];
    
    rHDR_n_exp = vertcat(rHDR_n_exp, rHDR_n);
    cbc_mean_exp = vertcat(cbc_mean_exp, cbc_mean); %#ok<*AGROW>
    pHDR_overlap_exp = vertcat(pHDR_overlap_exp,pHDR_overlap);
    psd_overlap_exp = vertcat(psd_overlap_exp,psd_overlap); 
    
    end % subloop (acquisition-level)    
    
    hdr_data.perROI.acq = acq;
    hdr_data.perROI.rHDR_n = rHDR_n_exp;
    hdr_data.perROI.cbc_values = cbc_mean_exp;
    hdr_data.perROI.pHDR_overlap = pHDR_overlap_exp;
    hdr_data.perROI.psd_overlap = psd_overlap_exp;
    save([folderN,dirname,'_hdrData.mat'],'hdr_data','-append')
    
    if multi == 1
        roi_n = length(acq);
        hdr_data_multi.perROI.experiment = vertcat(hdr_data_multi.perROI.experiment,repmat(exp(d),roi_n,1));    
        hdr_data_multi.perROI.acquisition = vertcat(hdr_data_multi.perROI.acquisition, acq);
        hdr_data_multi.perROI.rHDR_n = vertcat(hdr_data_multi.perROI.rHDR_n, rHDR_n_exp);
        hdr_data_multi.perROI.cbc_values = vertcat(hdr_data_multi.perROI.cbc_values, cbc_mean_exp);
        hdr_data_multi.perROI.pHDR_overlap = vertcat(hdr_data_multi.perROI.pHDR_overlap, pHDR_overlap_exp);
        hdr_data_multi.perROI.psd_overlap = vertcat(hdr_data_multi.perROI.psd_overlap, psd_overlap_exp);            
    end 
end % dir loop (experiment-level)
if multi == 1; save([folderP, parent_name,'_hdr_data_multi.mat'],'hdr_data_multi','-append'); end