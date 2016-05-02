function plotSparseWatershedAllDataPoints(jobTag,flyName,k)

% plotSparseWatershedAllDataPoints(jobTag,flyName,k)
% Plot results from sparse watershed algorithm applied to all data points (not just means)
%
% Inputs:
% jobTag [string]: folder where results of PCA20 GMM clustering and sparse watershed can be found
% flyName [string]: tag for fly whose data we want to load
% k [double]: PCA20 GMM k whose results fed our sparse watershed algorithm
%
% Figure 5C: plotSparseWatershedAllDataPoints('nmRound1','f37_1',200)

% Load the GMM model which generated these clusters
vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,k));
gmm=vars.gmm;

% Parse results by cluster number
pathCache=sprintf('~/results/%s/%s.mat',jobTag,jobTag);
if exist(pathCache,'file')
    vars=load(pathCache);
    resultsByCluster=vars.resultsByCluster;
else
    files=dir(sprintf('~/results/%s/%s_pca20gmmnm_%s_%d_*.mat',jobTag,jobTag,flyName,k));
    resultsByCluster={};
    NTotalResults=0;
    for iFile=1:length(files)
        file=files(iFile);
        tokens=regexp(file.name,sprintf('^%s_pca20gmmnm_%s_%d_(\\d+)\\.mat$',jobTag,flyName,k),'tokens');
        cluster=str2double(tokens{1}{1});
        assert(cluster>0);
        try
            vars=load(sprintf('~/results/%s/%s',jobTag,file.name));
        catch
            continue
        end
        % If we copy the file while it's saving it might not have results at all
        if isfield(vars,'results')
            results=vars.results;
            NResults=length(results);

            resultsByCluster{cluster}=[]; %#ok<AGROW>
            for iResult=1:NResults
                % If we copy the file while it's saving it might not have a certain field
                if isfield(results(iResult),'x')
                    iNext=length(resultsByCluster{cluster})+1;
                    resultsByCluster{cluster}(iNext).x=results(iResult).x;
                    resultsByCluster{cluster}(iNext).cluster=gmm.cluster(results(iResult).x);
                    NTotalResults=NTotalResults+1;
                end
            end
        end
    end
    save(pathCache,'resultsByCluster');
end

% Plot all results
iClusters=find(~cellfun('isempty',resultsByCluster));
NValidClusters=length(iClusters);
NTotalClusters=length(resultsByCluster);
plotv=6;
ploth=7;
numPlots=ceil(NValidClusters/(ploth*plotv));

% Calculates scores as percentage of clusters equal to the cluster closest to the mean
scores=[];
for iPlot=1:numPlots
    figure;
    for iSubPlot=1:min(plotv*ploth,NValidClusters-(iPlot-1)*plotv*ploth)
        subplot(plotv,ploth,iSubPlot);
        iCluster=plotv*ploth*(iPlot-1) + iSubPlot;
        cluster=iClusters(iCluster);
        
        % Grab this cluster's mean, sort results by distance to the mean
        clusterMean=gmm.mu(cluster,:);
        results=resultsByCluster{cluster};
        xs=vertcat(results.x);
        dists=pdist2(clusterMean,xs);
        [~,inds]=sort(dists);
        resultClusters=[results.cluster];
        sortedClusters=resultClusters(inds);
        if sortedClusters(1)==cluster; color='b'; else color='r'; end
        plot(1:length(sortedClusters),sortedClusters,color);
        xlim('manual');
        xlim([1 length(sortedClusters)]);
        ylim('manual');
        ylim([1 NTotalClusters]);
        
        % Compute score
        scores(end+1)=sum(sortedClusters==sortedClusters(1))/length(sortedClusters); %#ok<AGROW>
    end
end

% Plot scores
figure;
[n,x]=hist(scores,10);
bar(x,n/sum(n)*100);
title(sprintf('Sparse watershed consistency (mean %0.3f)',mean(scores)));
xlabel('Percentage of data points mapped to mean cluster');
ylabel('Percentage of total clusters');
