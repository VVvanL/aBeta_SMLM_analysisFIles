% working script to filter localizations based on attributes
%==========column headers==============
% {'frame'}    {'position_x'}    {'position_y'}    {'sigma'}    {'photons'}    {'background'}    {'precision'}
clearvars
%% select SMLM mat file for filtering
[file,path] = uigetfile();
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts
load([path,file],'data')

filters = struct();

filters.precision = [19 19]; %[maxch1 maxch2]
filters.photons = [300 300]; % [minch1 minch2]
filters.sigma = [75 250; 50 225]; %[min maxch1;min maxch2]
filters.background =[];

 for c = 1:2    
    c_fld = ['ch',num2str(c)];
    flt = ones(size(data.(c_fld).localizations,1),4);
    
    if numel(filters.precision) ~= 0
        flt(:,1) = data.(c_fld).localizations(:,7) <= filters.precision(c);
    end
    if numel(filters.photons) ~= 0
        flt(:,2) = data.(c_fld).localizations(:,5) >= filters.photons(c);
    end
    if numel(filters.sigma) ~= 0
        flt(:,3) = ...
            data.(c_fld).localizations(:,4) >= filters.sigma(c,1) & data.(c_fld).localizations(:,4) <= filters.sigma(c,2);
    end
    if numel(filters.background) ~= 0
        flt(:,4) = data.(c_fld).localizations(:,6) >= filters.background(c);
    end
    Flt = logical(min(flt,[],2));
    data.(c_fld).localizations = data.(c_fld).localizations(Flt,:);
 end
 
data.filters = filters;
save([path,file],'data','-append')
 