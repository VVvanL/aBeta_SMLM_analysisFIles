% working script to write summary HDR data to .csv file(s)
clearvars

%%Select hdr data file for .csv output

[file,path] = uigetfile('*hdrData.mat','Select hdrData file for csv output'); 
load([path, file],'hdr_data')
rootname = file(1:end-4);

perObj_temp = rmfield(hdr_data,{'perROI','center_hdr'});
perObj_hdrT = struct2table(perObj_temp);
writetable(perObj_hdrT,[path,rootname,'_perObj.csv'])

perRoi_hdrT = struct2table(hdr_data.perROI);
writetable(perRoi_hdrT,[path, rootname,'_perROI.csv'])



