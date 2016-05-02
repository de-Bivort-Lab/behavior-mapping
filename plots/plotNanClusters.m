function plotNanClusters(jobTag,jobTagSW,k)

% plotNanClusters(jobTag,jobTagSW,k)
% Plot nan vs wt fly cluster size distributions for each cluster in PCA20-GMM-SW co-fit data
%
% Inputs:
% jobTag [string]: folder containing PCA20-GMM results
% jobTagSW [string]: folder containing PCA20-GMM-SW results
% k [double]: original (not mapped) value of k for co-fit data

distCofit=plotCofit(jobTag,jobTagSW,k);
NClusters=size(distCofit,2);

% Take the mean of each individual fly's experiments
[flies,nanFlies,~,flyPrefixes]=allFlies();
allScores=zeros(length(flyPrefixes),NClusters);
iNanPrefixes=[];
iWtPrefixes=[];
for iPrefix=1:length(flyPrefixes)
    flyPrefix=flyPrefixes{iPrefix};
    iPrefixFlies=find(strncmp(flyPrefix,flies,length(flyPrefix)));
    prefixScores=mean(distCofit(iPrefixFlies,:),1);
    allScores(iPrefix,:)=prefixScores;
    
    if any(strcmp(flies{iPrefixFlies(1)},nanFlies))
        iNanPrefixes(end+1)=iPrefix; %#ok<AGROW>
    else
        iWtPrefixes(end+1)=iPrefix; %#ok<AGROW>
    end
end

% Now take the mean and stderr of nan and wt flies separately
nanMeanLogs=mean(log10(allScores(iNanPrefixes,:)),1);
nanLogMeans=log10(mean(allScores(iNanPrefixes,:),1));
nanSEs=std(allScores(iNanPrefixes,:),1,1);

wtMeanLogs=mean(log10(allScores(iWtPrefixes,:)),1);
wtLogMeans=log10(mean(allScores(iWtPrefixes,:),1));
wtSEs=std(allScores(iWtPrefixes,:),1,1);

% Now scatter plot nan vs wt
figure;
scatter(nanMeanLogs, wtMeanLogs);
axis square;
xlabel('nan means of log10(scores)');
ylabel('wt means of log10(scores)');

% Now scatter plot nan vs wt
figure;
scatter(nanLogMeans, wtLogMeans);
axis square;
xlabel('log10(nan means)');
ylabel('log10(wt means)');
