function [clusterDimEnergy,clusterDimEnergyByFly]=plotCofitFrameEnergies(jobTag,k,flyNames)

% [clusterDimEnergy,clusterDimEnergyByFly]=plotCofitFrameEnergies(jobTag,k,flyNames)
% Plot cluster energies by dimension for co-fit data
%
% Inputs:
% jobTag [string]: folder where results can be found
% k [double]: number of co-fit clusters in results to plot
% flyNames [1 x NFlies string]: names for flies whose data we want to analyze and average
%
% Outputs:
% clusterDimEnergy [k x NDims]: average energy per dimension for each cluster, averaged across flies
% clusterDimEnergyByFly [k x NDims x NFlies]: average energy per dimension for each cluster, separated by fly
%
% Figure 8B: [clusterDimEnergy,clusterDimEnergyByFly]=plotCofitFrameEnergies('swRound1',40,allFlies())

pathCache=sprintf('~/results/%s/cofit_frame_energies.mat',jobTag);

if exist(pathCache,'file')
    vars=load(pathCache);
    clusterDimEnergy=vars.clusterDimEnergy;
    clusterDimEnergyByFly=vars.clusterDimEnergyByFly;
    
else
    % Load clusterings for all flies
    vars=load(sprintf('~/results/%s/%s_pca20gmmswmapped_all_%d.mat',jobTag,jobTag,k));
    finalClustersByFly=vars.finalClustersByFly;

    % Process each fly
    NDims=15;
    NFlies=length(flyNames);
    clusterDimEnergyByFly=zeros(k,NDims,NFlies);
    for iFly=1:length(flyNames)
        flyName=flyNames{iFly};
        fprintf('Processing %s (%d of %d)...\n',flyName,iFly,length(flyNames));

        % Load this fly's high-variance frame-normalized wavelet data
        hvfnData=loadHighVarFNData(flyName);
        NScales=size(hvfnData,2)/NDims;

        % Load clusterings, process each cluster
        clusters=finalClustersByFly(flyName);
        assert(length(clusters)==size(hvfnData,1));
        for iCluster=1:k
           clusterData=hvfnData(clusters==iCluster,:);
           % Process each dim
           for iDim=1:NDims
               % Take CFS coefficients for this dim, sum across scales and take the mean across frames
               iFirst=1 + (iDim-1)*NScales;
               iLast=iFirst+NScales-1;
               dimData=clusterData(:,iFirst:iLast);
               dimEnergy=mean(sum(dimData,2));
               clusterDimEnergyByFly(iCluster,iDim,iFly)=dimEnergy;
           end       
        end
    end

    % Now take the mean across flies, note that we ignore nans here since some 
    clusterDimEnergy=squeeze(nanmean(clusterDimEnergyByFly,3));
    save(pathCache,'clusterDimEnergy','clusterDimEnergyByFly');
end

figure;
DimNames=standardDimNames();
imagesc(clusterDimEnergy);
title('Energy by cluster and dim');
set(gca,'XTick',1:length(DimNames));
set(gca,'XTickLabel',DimNames);
ylabel('cluster number');
