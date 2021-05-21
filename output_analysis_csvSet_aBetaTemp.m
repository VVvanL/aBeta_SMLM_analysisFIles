% working script to generate analysis csv sets for SMLM data
% NOTE: current version assumes deliniated alphaShape for PSD synRegion

clearvars; close all
%=============
multi = 0; % set to 1 if looping through multiple condition/experimental directories (each with acquisitional subdirectories)
conditions = {''}; % conditions in dataset. Note: case-sensitive, exact match to subdirectory naming protocol
p_ch = 2; % PSD channel
q_ch = 1; % query channel, e.g. receptor, soluble signaling component, etc (primary hdr analysis output)
q_label = 'aBeta'; % label for query specific output files
%=============
n_cnd = size(conditions,2);

if multi == 1
    folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
    dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = []; 
    dir_n = size(dirlist,1); folderP = [folderP,filesep];
    % structures for aggregated data from multiple experiments
    metricsME = struct();
    metricsME.synregions = cell(n_cnd,2);
    metricsME.nanoregions = cell(n_cnd,2); % column per channel, row per condition    
    metricsME.([q_label,'_hdrMetrics']) = cell(n_cnd,2); % columns: perROI; perHDR
    metricsME.cbc = cell(n_cnd,2);
else    
    folderN = uigetdir; folderN = [folderN,filesep];   
    dir_n = 1;
end

%% loop through experiments (dir_n = 1 in the case of single-experiment)
for d = 1:dir_n
    if multi == 1; folderN = [folderP,filesep,dirlist(d).name,filesep]; end
    foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts 
    sublist = dir(folderN); sublist = sublist([sublist.isdir]); sublist(1:2) = []; sub_n = size(sublist,1);
    
    % structures for experiment-level data    
    metrics = struct();
    metrics.synregions = cell(n_cnd,2);
    metrics.nanoregions = cell(n_cnd,2); % column per channel, row per condition    
    metrics.([q_label,'_hdrMetrics']) = cell(n_cnd,2); % columns: perROI; perHDR, row per condition
    metrics.cbc = cell(n_cnd,2);
    
    for s = 1:sub_n    
        subname = sublist(s).name; subpath = fullfile(sublist(s).folder,subname,filesep);
        smlm = dir([subpath,'*SMLM.mat']); load([subpath,smlm.name],'roiData')
        roinames = fieldnames(roiData.ch1); roi_n = length(roinames);        
        csvdir = [subpath,subname,'_csvFiles',filesep];
        if ~exist(csvdir,'dir'); mkdir(csvdir); end 
        
        % preallocate cell-array for storage of querry coordinate data (distribution and hdr)        
        perROI = cell(roi_n,8); 
        perHDR = cell(nansum(roiData.nanoRegions{1,q_ch}(:,1)),6); rw_hdr = 0; % querry coordinate hdr data metrics
        
        for roi = 1:roi_n
            r_fld = roinames{roi};
            q_fld = ['ch',num2str(q_ch)]; p_fld = ['ch',num2str(p_ch)];

            perROI{roi,1} = {subname}; perROI{roi,2} = roi;
            if isnan(roiData.synRegions{1,q_ch}(roi,1))
                perROI{roi,3} = 'dispersed';
                perROI{roi,4} = NaN; perROI{roi,5} = NaN; perROI{roi,6} = NaN; perROI{roi,7} = NaN;
            else 
                perROI{roi,3} = 'clustered';
                perROI{roi,4} = length(roiData.(q_fld).(r_fld).synRegion.xy); % total number of clustered receptor localizations
                if isnan(roiData.nanoRegions{1,q_ch}(roi,1)) || isnan(roiData.synRegions{1,p_ch}(roi,1))
                    perROI{roi,5} = NaN; perROI{roi,6} = NaN; perROI{roi,7} = NaN;              
                else
                    perROI{roi,5} = length(roiData.(q_fld).(r_fld).nanocluster.regions.hdr_data.in_psd{:}); % receptor locs in PSD
                    perROI{roi,6} = length(roiData.(q_fld).(r_fld).nanocluster.n1.xy); % high-density localizations
                    perROI{roi,7} = roiData.(q_fld).(r_fld).nanocluster.regions.region_n; % number of high density regions
                end                
            end
            if ~isnan(roiData.synRegions{1,p_ch}(roi,1))
                xy = roiData.(q_fld).(r_fld).localizations(:,3:4); % get all querry coordinates            
                psd = roiData.(p_fld).(r_fld).synRegion.regions.shp; % get psd alphaShape
                tf = inShape(psd,xy); % find q_coordinates in PSD region
                perROI{roi,8} = sum(tf) / sum(roiData.(p_fld).(r_fld).synRegion.regions.region_area); % density of q-coords in PSD
            else; perROI{roi,8} = NaN;
            end
            
            roiData.(q_fld).(r_fld).classification = perROI{roi,3};
            roiData.(q_fld).(r_fld).density_in_psd = perROI{roi,8};
            
            if ~isnan(roiData.nanoRegions{1,q_ch}(roi,1)) && roiData.nanoRegions{1,q_ch}(roi,1) ~= 0 ...
                    && isfield(roiData.(q_fld).(r_fld).nanocluster.regions,'hdr_data')                    
                for h = 1:perROI{roi,7}
                    rw_hdr = rw_hdr + 1;
                    perHDR{rw_hdr,1} = {subname};
                    perHDR{rw_hdr,2} = roi;
                    perHDR{rw_hdr,3} = length(roiData.(q_fld).(r_fld).nanocluster.regions.hdr_data.hdr_xy{2,h});
                    perHDR{rw_hdr,4} = roiData.(q_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{1,h};
                    perHDR{rw_hdr,5} = roiData.(q_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{2,h};
                    perHDR{rw_hdr,6} = roiData.(q_fld).(r_fld).nanocluster.regions.hdr_data.hdr_rg{3,h};        
                end
%             else
%                 rw_hdr = rw_hdr + 1;
%                 perHDR{rw_hdr,1} = {subname};
%                 perHDR{rw_hdr,2} = roi;
%                 perHDR{rw_hdr,3} = 0;
%                 perHDR{rw_hdr,4} = NaN; perHDR{rw_hdr,5} = NaN; perHDR{rw_hdr,6} = NaN;
            end
            perHDR(rw_hdr + 1:end,:) = [];
            roiData.([q_label,'_perROI']) = perROI;
            roiData.([q_label,'_perHDR']) = perHDR;

                        
            %% get general synaptic and hdr metrics for both channels
            for c = 1:2
                c_fld = ['ch',num2str(c)];
                
                %% extract per hd(nano)-region data, append to existing roiData.nanoRegions field
                nano_temp = [];
                if isfield(roiData.(c_fld).(roinames{roi}),'nanocluster') && ...
                        isfield(roiData.(c_fld).(roinames{roi}).nanocluster,'regions') && ...
                        isfield(roiData.(c_fld).(roinames{roi}).nanocluster.regions,'region_n')
                    n = roiData.(c_fld).(roinames{roi}).nanocluster.regions.region_n; % for readability, allows repmat of roi number
                    A = roiData.(c_fld).(roinames{roi}).nanocluster.regions.region_area;
                    nano_temp = vertcat(nano_temp,[repmat(roi,n,1),A']); %#ok<AGROW>                 
                end
                % extract cbc data
                if roi ~= 1; roiData.nanoRegions{2,c} = vertcat(roiData.nanoRegions{2,c}, nano_temp); % appends to existing field
                else; roiData.nanoRegions{2,c} = nano_temp; end
                
            end % ==========channel loop=========          
        end % ===========roi loop================
        
        %% assemble, write tables for per acquisition data        
        
        % general synaptic metrics for both channels ==========
        synMetricsT = cell(1,2); nanoMetricsT = cell(1,2);

        varnames = {'roi','synReg_Num','synReg_Area','synReg_LocNum','synReg_LDmean','synReg_LDstd',...
            'hdr_Num','hdr_Area','hdr_LocNum','hdr_LDmean','hdr_LDstd'}; 
        acqT = table('Size',[roi_n,1],'VariableTypes',{'string'},'VariableNames',{'acquisition'});
        acqT{:,1} = repmat({subname},roi_n,1); % aquisition designation for synMetics
       
        % write general synaptic metrics (aqusition-level); assemble experiment level data
        for c = 1:2
            synMetricsT{c} = array2table([(1:roi_n)',roiData.synRegions{c},roiData.nanoRegions{1,c}],...
                'VariableNames',varnames);
            synMetricsT{c} = [acqT,synMetricsT{c}];
            writetable(synMetricsT{c},[csvdir,subname,'_synMetrics_ch',num2str(c),'.csv'])
            nanoMetricsT{c} = array2table(roiData.nanoRegions{2,c},'VariableNames',{'roi','area_nm2'});
            acqN_T = table('Size',[size(nanoMetricsT{c},1),1],'VariableTypes',{'string'},'VariableNames',{'acquisition'});
            acqN_T{:,1} = repmat({subname},size(nanoMetricsT{c},1),1); 
            nanoMetricsT{c} = [acqN_T,nanoMetricsT{c}];
            writetable(nanoMetricsT{c},[csvdir,subname,'_hdRegions_ch',num2str(c),'.csv'])
            
            %% assemble tables for experiement-level cvs set            
            for cnd = 1:n_cnd
                % determine condition-type of subdir data and store in appropriate cell element of experiment-level cell array
                if ~contains(subname,conditions{cnd})
                    continue % restart loop
                else            
                    if numel(metrics.synregions{cnd,c}) ~= 0 % determine if pass contains first data for structure  
                        metrics.synregions{cnd,c} = vertcat(metrics.synregions{cnd,c},synMetricsT{c});
                        metrics.nanoregions{cnd,c} = vertcat(metrics.nanoregions{cnd,c},nanoMetricsT{c});                       
                    else
                        metrics.synregions{cnd,c} = synMetricsT{c};
                        metrics.nanoregions{cnd,c} = nanoMetricsT{c};
                    end                
                end % 
            end % subloop through experimental conditions            
        end % channel loop for general region metrics , write tables to acquisition folder
        
        % querry coordinate HDR data=============================
        perROI_t = cell2table(perROI,'VariableNames',...
            {'acquisition','ROI','classification','totalLocs','locs_inPSD','high_density_locs','num_hdregions','density_in_psd'});
        writetable(perROI_t,[csvdir,subname,'_perROI_',q_label,'_Data.csv'])
        
        perHDR_t = cell2table(perHDR,'VariableNames',{'acquisition','ROI','num_locs','area','PSD_hdr_overlap','PSD_overlap'});
        writetable(perHDR_t,[csvdir,subname,'_perHDR_',q_label,'_Data.csv'])
        
        % conditions loop for querry-coordinate HDR data, in a seperate loop for readability
        for cnd = 1:n_cnd
            if ~contains(subname,conditions{cnd})
                    continue % restart loop
            else
                if numel(metrics.([q_label,'_hdrMetrics']){cnd,1}) ~= 0
                    metrics.([q_label,'_hdrMetrics']){cnd,1} = ...
                        vertcat(metrics.([q_label,'_hdrMetrics']){cnd,1}, perROI_t);
                    metrics.([q_label,'_hdrMetrics']){cnd,2} = ...
                        vertcat(metrics.([q_label,'_hdrMetrics']){cnd,2}, perHDR_t);            
                else
                    metrics.([q_label,'_hdrMetrics']){cnd,1} = perROI_t;
                    metrics.([q_label,'_hdrMetrics']){cnd,2} = perHDR_t;
                end
            end            
        end       

        save([subpath,smlm.name],'roiData','-append')
        
    end % subdirectory loop (acqusition level)========================================
    
    %% write experment-level data/tables; assemble multi-experiment level metrics(if applicable)
    
    save([folderN,dirname,'_metrics.mat'],'metrics','q_label','conditions');    
    
    % write .csv tables
    for cnd = 1:n_cnd
        writetable(metrics.([q_label,'_hdrMetrics']){cnd,1},...
                [folderN,dirname,'_',conditions{cnd},'_',q_label,'_perROImetrics.csv'])
        writetable(metrics.([q_label,'_hdrMetrics']){cnd,2},...
                [folderN,dirname,'_',conditions{cnd},'_',q_label,'_perHDRmetrics.csv'])
            
            for c = 1:2
                writetable(metrics.synregions{cnd,c},[folderN,dirname,'_',conditions{cnd},'_synMetrics_ch',num2str(c),'.csv'])            
                writetable(metrics.nanoregions{cnd,c},[folderN,dirname,'_',conditions{cnd},'_hdRegions_ch',num2str(c),'.csv']) 
            end
    end   
    
    % assemble multi-experiment level data
    if multi == 1
        for cnd = 1:n_cnd
            if numel(metricsME.([q_label,'_hdrMetrics']){cnd,1}) ~= 0
                metricsME.([q_label,'_hdrMetrics']){cnd,1} = ...
                    vertcat(metricsME.([q_label,'_hdrMetrics']){cnd,1}, metrics.([q_label,'_hdrMetrics']){cnd,1});
                metricsME.([q_label,'_hdrMetrics']){cnd,2} = ...
                    vertcat(metricsME.([q_label,'_hdrMetrics']){cnd,2}, metrics.([q_label,'_hdrMetrics']){cnd,2});
            else
                metricsME.([q_label,'_hdrMetrics']){cnd,1} = metrics.([q_label,'_hdrMetrics']){cnd,1};
                metricsME.([q_label,'_hdrMetrics']){cnd,2} = metrics.([q_label,'_hdrMetrics']){cnd,2};
            end            

            for c = 1:2
                if numel(metricsME.synregions{cnd,c}) ~= 0 % determine if pass contains first data for structure
                    metricsME.synregions{cnd,c} = vertcat(metricsME.synregions{cnd,c},metrics.synregions{cnd,c});
                    metricsME.nanoregions{cnd,c} = vertcat(metricsME.nanoregions{cnd,c},metrics.nanoregions{cnd,c});
                else
                    metricsME.synregions{cnd,c} = metrics.synregions{cnd,c};
                    metricsME.nanoregions{cnd,c} = metrics.nanoregions{cnd,c};
                end               
            end
        end    
    end
end % =============directory loop (experiment level)===================

if multi == 1
    save([folderP,parent_name,'_metrics.mat'],'metricsME','conditions','q_label');

    for cnd = 1:n_cnd
        writetable(metricsME.([q_label,'_hdrMetrics']){cnd,1}, ...
            [folderP,parent_name,'_',conditions{cnd},'_',q_label,'_perROImetrics.csv'])
        writetable(metricsME.([q_label,'_hdrMetrics']){cnd,2}, ...
            [folderP,parent_name,'_',conditions{cnd},'_',q_label,'_perHDRmetrics.csv'])
        for c = 1:2
            writetable(metricsME.synregions{cnd,c},[folderP,parent_name,'_',conditions{cnd},'_synMetrics_ch',num2str(c),'.csv'])            
            writetable(metricsME.nanoregions{cnd,c},[folderP,parent_name,'_',conditions{cnd},'_hdRegions_ch',num2str(c),'.csv'])        
        end    
    end

end