function [m0,m1]=plotMarkov(jobTag,flyName,method)

% plotMarkov(jobTag,flyName,method)
% Figure showing histogram of state occupancies and markov transition matrix for a single fly
%
% Inputs:
% jobTag [string]: folder where results can be found
% flyName [string]: tag for fly we're processing
% method [string]: mapping method to load, taken from p20gsw, t2w, p20g, t2g, p2w, p2g, r
%
% Outputs:
% m0 [NClusters+1 x 1 double]: Zeroth-order Markov transition matrix (i.e. state occupancy histogram)
% m1 [NClusters+1 x NClusters+1 double]: First-order Markov transition matrix
%
% Figure 6A,C: plotMarkov('swRound1','f37_1','p20gsw')

% Load the given fly's clusters
[allClusters,numClusters]=loadClustersSW(jobTag,flyName,true);
clusters=allClusters.(method);

% Compute Markov matrices
[m0,m1]=markovTransitionMatrices(numClusters,clusters);

% Plot state occupancies and transition matrix
figure;
subplot(121);
bar(0:numClusters,m0);
xlabel('clusters');
ylabel('state occupancy fraction');
title(sprintf('%s/%s/%s Markov 0th order transition matrix',jobTag,flyName,method));

subplot(122);
% show just off-diagonal elements:
%m1Plot=m1-diag(diag(m1));
% log scale:
m1Plot=log10(m1);
imagesc(m1Plot);
colormap(cmapStandard1());
colorbar;
xlabel('to cluster');
ylabel('from cluster');
set(gca,'XTick',0:10:numClusters);
set(gca,'XTickLabel',sprintfc('%d',0:10:numClusters));
set(gca,'YTick',0:10:numClusters);
set(gca,'YTickLabel',sprintfc('%d',0:10:numClusters));
title(sprintf('%s/%s/%s Markov 1st order transition matrix',jobTag,flyName,method));
