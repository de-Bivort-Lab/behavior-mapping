function plotGMMPosteriors(jobTag)

% plotGMMPosteriors()
% Figure showing distribution of GMM posterior probability ratios
%
% Inputs:
% jobTag [string]: the results we use here

% Gather data across all of our flies
pathCache=sprintf('~/results/%s/pmax.mat',jobTag);
if exist(pathCache,'file')
    vars=load(pathCache);
    allPMax=vars.allPMax;
else
    allPMax={};

    flies=allFlies();
    parfor iFly=1:length(flies)
        flyName=flies{iFly};
        % Load the PCA-compressed high-variance frame-normalized data we used in the gmm classification
        cfspcData=loadCFSPCData(flyName);

        % Load this fly's t-SNE2 watershed mapping results, use its watershed count for our k
        vars=load(sprintf('~/results/%s/%s_tsne2wshed_%s.mat',jobTag,jobTag,flyName));
        numWatersheds=vars.numWatersheds;

        % Load the corresponding PCA20 GMM clustering
        vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,numWatersheds));
        gmm=vars.gmm;

        % Compute maximum posterior probabilities
        P=gmm.posterior(cfspcData);
        PMax=max(P,[],2);
        allPMax{iFly}=PMax;
    end

    % Save results
    save(pathCache,'allPMax');
end

% Gather all of our max posterior probabilities in a single vector
allPMax=cell2mat(allPMax');

% Plot the distribution of maximum posterior probabilities
figure;
[n,x]=hist(allPMax,20);
bar(x,n/sum(n));
xlabel('max posterior');
ylabel('fraction of frames with max posterior < x');
title('GMM posterior probabilities');

% Plot the cumulative distribution of maximum posterior probabilities
figure;
[n,x]=hist(allPMax,20);
bar(x,cumsum(n/sum(n)));
xlabel('max posterior');
ylabel('fraction of frames with max posterior < x');
title('GMM posterior probabilities (cumulative)');
