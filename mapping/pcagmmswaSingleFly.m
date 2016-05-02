function pcagmmswaSingleFly(jobTag,flyName,gmmk,cluster,pathResult)

% pcagmmswaSingleFly(jobTag,flyName,gmmk,cluster,pathResult)
% Run PCA20 GMM sparse watershed (all data points) clustering on a single fly
%
% Inputs:
% jobTag [string]: folder where we load PCA20 GMM results
% flyName [string]: tag for fly we're processing
% gmmk [double]: PCA20 GMM k we use for our sparse watershed algorithm
% cluster [double]: PCA20 GMM cluster whose data points we analyze
% pathResult [string]: path to file where we save results
%
% Results:
% results [NDataPoints x 1 struct]: struct array with fminunc results for each data point

% Load the GMM from the given results
vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,gmmk));
gmm=vars.gmm;
clusters=vars.clusters;

% Load our PCA-compressed high-variance frame-normalized wavelet data, this is what we fed to GMM
cfspcData=loadCFSPCData(flyName);

% Look at all frames with the given cluster assignment, use a random order
clusterFrames=find(clusters==cluster);
NFrames=length(clusterFrames);
inds=randperm(NFrames);
clusterFrames=clusterFrames(inds);

results=struct();
for iFrame=1:NFrames
    % Grab this frame's coords
    frame=clusterFrames(iFrame);
    results(iFrame).frame=frame;
    fprintf('%s | %s | k=%d cluster=%d | Processing frame %d of %d (%d)...\n',jobTag,flyName,gmmk,cluster,iFrame,NFrames,frame);
    x0=cfspcData(frame,:);
    
    tic;
    % Run gradient descent on each data point, we invert the PDF to find its maximum and scale by 1e-30 to bring the PDFs values into
    % a more typical range for fminunc
    options=optimoptions('fminunc','Algorithm','quasi-newton','ObjectiveLimit',-1e100,'HessUpdate','steepdesc','Display','final-detailed',...
        'MaxFunEvals',inf);
    [results(iFrame).x,results(iFrame).fval,results(iFrame).exitflag,results(iFrame).output,results(iFrame).grad]=fminunc(@(x)-gmm.pdf(x)*1e-30,x0,options);
    toc;
    
    % Save results each iteration so we can use them before we sample all of this cluster's frames
    save(pathResult,'results');
end
