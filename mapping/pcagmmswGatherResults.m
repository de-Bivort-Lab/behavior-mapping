function pcagmmswGatherResults(jobTag)

% pcagmmswGatherResults(jobTag)
% Gather results from our pcagmmswRunSingleFlies run
%
% Inputs:
% jobTag [string]: folder where pcagmmswRunSingleFlies results are stored
%
% Results:
% gmm [gmdistribution]: Gaussian Mixture Model fit to PCA-compressed high-variance frame-normalized wavelet data
% mappedClusterMeans [NUnmappedClusters x 1]: consolidated cluster to which each unmapped cluster maps
% finalClustersByFly [string -> NHighVarFrames x 1]: consolidated cluster assignment for each frame, keyed by fly name

% Look at all result files in the given folder
files=dir(sprintf('~/results/%s/%s_pca20gmmsw_*.mat',jobTag,jobTag));
for iFile=1:length(files)
    file=files(iFile);

    % Parse our fly name and k from the filename
    tokens=regexp(file.name,sprintf('^%s_pca20gmmsw_(.+)_(\\d+?)\\.mat$',jobTag),'tokens');
    flyName=tokens{1}{1};
    k=str2double(tokens{1}{2});
    assert(k>0);
    
    % Load results and corresponding GMM model, cluster the results
    varsGMM=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,k));
    gmm=varsGMM.gmm;
    
    vars=load(sprintf('~/results/%s/%s',jobTag,file.name));
    results=vars.results;
    assert(gmm.NumComponents==length(results));
    
    mappedClusterMeans=zeros(length(results),1);
    for iCluster=1:length(results)
        mappedClusterMean=gmm.cluster(results(iCluster).x);
        mappedClusterMeans(iCluster)=mappedClusterMean;
    end
    uniqueMappedClusterMeans=unique(mappedClusterMeans);
    mappedK=length(uniqueMappedClusterMeans);
    fprintf('%s/%d: %d unique mapped clusters, %d map to self\n',flyName,k,mappedK,sum(mappedClusterMeans==(1:length(results))'));
    
    if strcmp(flyName,'all')
        % For co-fit flies, map clusters for each fly and save them
        clustersByFly=varsGMM.clusters_by_fly;
        finalClustersByFly=containers.Map();%('KeyType','char', 'ValueType','any');
        for clusterFlyNameCell=allFlies()
            clusterFlyName=clusterFlyNameCell{1};
            finalClustersByFly(clusterFlyName)=mapClusters(clustersByFly(clusterFlyName),mappedClusterMeans,uniqueMappedClusterMeans);
        end
        % Save our new clusterings
        pathResult=sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,mappedK);
        save(pathResult,'gmm','mappedClusterMeans','finalClustersByFly');
    else
        % For non co-fit flies, map our clusters and save them
        clusters=varsGMM.clusters;
        finalClusters=mapClusters(clusters,mappedClusterMeans,uniqueMappedClusterMeans); %#ok<NASGU>
        
        % Save our new clustering
        pathResult=sprintf('~/results/%s/%s_pca20gmmswmapped_%s_%d.mat',jobTag,jobTag,flyName,mappedK);
        save(pathResult,'gmm','mappedClusterMeans','finalClusters');
    end
end

    function finalClusters=mapClusters(clusters,mappedClusterMeans,uniqueMappedClusterMeans)
        % Map the given clusters, renumber them 1:mappedK

        % First convert to our mapped clusters, after this not every cluster will be assigned
        mappedClusters=zeros(length(clusters),1);
        for iClusterMean=1:length(mappedClusterMeans)
            mappedClusters(clusters==iClusterMean)=mappedClusterMeans(iClusterMean);
        end
        % Now renumber so every cluster is assigned and max(finalClusters)==numMappedClusters
        finalClusters=zeros(length(clusters),1);
        for iUniqueClusterMean=1:length(uniqueMappedClusterMeans)
            finalClusters(mappedClusters==uniqueMappedClusterMeans(iUniqueClusterMean))=iUniqueClusterMean;
        end
        assert(min(finalClusters)>=1 && max(finalClusters)<=length(uniqueMappedClusterMeans));
    end
end
