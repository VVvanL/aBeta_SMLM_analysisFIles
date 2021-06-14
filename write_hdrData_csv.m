% working script to write summary HDR data to .csv file(s)
clearvars

selectedROI = 1; % flag if output is to include selected ROIs only

folderP = uigetdir; foldparts = strsplit(folderP,filesep); parent_name = foldparts{end}; clear foldparts
dirlist = dir(folderP); dirlist = dirlist([dirlist.isdir]); dirlist(1:2) = [];
dir_n = size(dirlist,1); folderP = [folderP,filesep];
load([folderP, parent_name,'_hdr_data_multi.mat'],'hdr_data_multi')
load([folderP, parent_name,'_psd_data_multi.mat'],'psd_data_multi','ch_str')


% [file,path] = uigetfile('*hdrData.mat'); load([path, file],'hdr_data')
% rootname = file(1:end-4);
% 
% perObj_temp = rmfield(hdr_data,{'perROI','center_hdr'});
% perObj_hdrT = struct2table(perObj_temp);
% writetable(perObj_hdrT,[path,rootname,'_perObj.csv'])
% 
% perRoi_hdrT = struct2table(hdr_data.perROI);
% writetable(perRoi_hdrT,[path, rootname,'_perROI.csv'])



% for selectedROIs
perObj_hdrT = struct2table(hdr_data_multi.ROIsubset);
writetable(perObj_hdrT,[folderP,parent_name,'_perObj_rhdrData.csv'])

perRoi_hdrT = struct2table(hdr_data_multi.perROI.ROIsubset);
writetable(perRoi_hdrT,[folderP,parent_name,'_perROI_rhdrData.csv'])

perROI_psdT = struct2table(psd_data_multi.ROIsubset.perROI);
writetable(perROI_psdT,[folderP,parent_name,'_perROI_psdData.csv'])

temp = rmfield(psd_data_multi,'ROIsubset');
perObj_psdT = struct2table(temp);
writetable(perObj_psdT,[folderP,parent_name,'_perObj_psdData.csv'])
