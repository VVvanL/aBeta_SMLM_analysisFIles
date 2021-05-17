% Note: SRPipeline must be in search path

%%
rootname = 'cell1_200812'; % use if abbrevied file name is desiered 

[file,path] = uigetfile();
foldparts = strsplit(path,filesep); dirname = foldparts{end-1}; clear foldparts
load([path,file])
if ~exist('rootname','var'); rootname = file(1:end-4); end

%% initiate needed structures
p = struct;     %contains all the parameters
data = struct;  %contains all the data

%% define parameters
% short list of acquisition parameters needed for downstream analysis
p.acq.nchannels = obj.acq.nchannels;          % number of channels acquired in experiment
p.Tstorm.camera.pixelsize = obj.Tstorm.camera.pixelsize;  % pixelsize in nm for raw timeseries acquisition
p.image_gen.pixelsize_g = 10; % pixel size of SR image used to draw ROIs (in nm)

for c = 1:p.acq.nchannels
    c_fld = ['ch' num2str(c)];
    locT = struct2table(obj.SML_data.(c_fld));  
    data.(c_fld).colheaders = locT.Properties.VariableNames;
    data.(c_fld).localizations = table2array(locT);
    clear locT    
end
save([path,rootname,'_SMLM.mat'],'p','data')