function pcagmmswSingleFly(jobTag,flyName,gmmk,pathResult)

% pcagmmswSingleFly(jobTag,flyName,gmmk,pathResult)
% Run PCA20 GMM sparse watershed (mean-only) clustering on a single fly
%
% Inputs:
% jobTag [string]: folder where we load PCA20 GMM results
% flyName [string]: tag for fly we're processing
% gmmk [double]: PCA20 GMM k we use for our sparse watershed algorithm
% pathResult [string]: path to file where we save results
%
% Results:
% results [gmmk x 1 struct]: struct array with fminunc results for each data point

% Load the GMM from the given results
vars=load(sprintf('~/results/%s/%s_pca20gmm_%s_%d.mat',jobTag,jobTag,flyName,gmmk));
gmm=vars.gmm;
assert(size(gmm.mu,1)==gmmk);

results=struct();
for iCluster=1:gmmk
    % Grab this cluster's mean coords
    fprintf('%s | %s | k=%d | Processing cluster %d of %d...\n',jobTag,flyName,gmmk,iCluster,gmmk);
    x0=gmm.mu(iCluster,:);
    
    tic;
    % Run gradient descent on each data point, we invert the PDF to find its maximum and scale by 1e-30 to bring the PDFs values into
    % a more typical range for fminunc
    options=optimoptions('fminunc','Algorithm','quasi-newton','ObjectiveLimit',-1e100,'HessUpdate','steepdesc','Display','final-detailed',...
        'MaxFunEvals',inf,'MaxIter',5000);
    [results(iCluster).x,results(iCluster).fval,results(iCluster).exitflag,results(iCluster).output,results(iCluster).grad]=fminunc(@(x)-gmm.pdf(x)*1e-30,x0,options);
    toc;
end

save(pathResult,'results');
