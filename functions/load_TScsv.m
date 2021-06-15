function s=load_TScsv(filepath)

    s = importdata(filepath,',');
    s = rmfield(s,'textdata');
    s.colheaders = {'id','frame','x [nm]','y [nm]','sigma [nm]','intensity [photons]','offset [photon]','bkgstd [photon]','chi2','uncertainty [nm]'};
    s.localizations = s.data; s = rmfield(s,'data');
    s.parameterStats = []; % placeholder
    parameterHeaders = {'sigma_nm','intensity_photons','offset_photon','bkgstd_photon','chi2','uncertainty_nm'};
    
    % calculate parameterStats
    for p = 5:length(s.colheaders) % start parameter stats calculations with sigma
        s.parameterStats.(parameterHeaders{p-4}) = parameterStats(s.localizations(:,p));      
    end
end