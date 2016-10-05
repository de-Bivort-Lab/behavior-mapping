function out=motif2DGMMMonteCarlo

% out=motif2DGMMMonteCarlo
% Perform Markov Chain Monte Carlo to position standard 2d Gaussians in a plane to match 1) the
% distribution of pairwise distances between their centroids and 2) the distribution of maximum
% posterior probabilities for points randomly sampled from that plane, to the distributions
% observed in our PCA20-GMM fits. Produces Figure 5A.

targetHist=[0;0;0;0.000166483434898228;0.000942906180835007;...
    0.00294970650420283;0.00642936027865227;0.0111988857108718;...
    0.0164983584133379;0.0217978311158040;0.0292970849400485;...
    0.0382961895291419;0.0373962790702325;0.0371962989682527;...
    0.0377962392741922;0.0391960999880512;0.0411959010078497;...
    0.0456054622565055;0.0524947767697114;0.0649935331434522;...
    0.0935906877265712;0.422957915687389]';

distHist=[0.00555555555555556,0,0.000370370370370370,0.00691358024691358,0.0348765432098765,0.0826543209876543,0.119876543209877,0.133518518518519,0.128333333333333,0.113518518518519,0.102283950617284,0.0808024691358025,0.0647530864197531,0.0543209876543210,0.0355555555555556,0.0190123456790123,0.0101234567901235,0.00438271604938272,0.00246913580246914,0.000493827160493827,0.000185185185185185,0];

nModes=180;
modeStd=0.1;
imSize=5;
means=rand(nModes,2)*imSize;

gridSize=ceil(sqrt(nModes));
grid1=linspace(0,1,gridSize);
xCoords=repmat(grid1,gridSize,1);
yCoords=repmat(grid1',1,gridSize);
xCoords=xCoords(:);
yCoords=yCoords(:);
means=[xCoords(1:nModes) yCoords(1:nModes)]*imSize;

nReps=20000;
nSamples=3000;
numToTweak=10;
tweakRadius=10*modeStd;
distHistWeight=15;

scoreBest=Inf;
meansBest=means;
% PDFBest=PDFtemp;
histBest=[];
pdBest=[];


figure; hold on;
h=waitbar(0);
for i=1:nReps;

    
    %     PDFtemp=PDFBest;
    meansTemp=meansBest;
    tweakR=tweakRadius*(nReps-i)/nReps;
    nTT=ceil(numToTweak*(nReps-i)/nReps);
    whichToTweak=randperm(nModes);
    whichToTweak=whichToTweak(1:nTT);
    meansTemp(whichToTweak,:)=meansTemp(whichToTweak,:)+randn(nTT,2)*tweakR;
    
    pdTemp=squareform(pdist(meansTemp));
    
    sampleTemp=zeros(nSamples,1);
    for j=1:nSamples
        whichMode=ceil(rand()*nModes);
        x=randn()*modeStd+meansTemp(whichMode,1);
        y=randn()*modeStd+meansTemp(whichMode,2);
        distsToAllModes=sqrt((x-meansTemp(:,1)).^2+(y-meansTemp(:,2)).^2);
        posteriors=normpdf(distsToAllModes,0,modeStd);
        sampleTemp(j)=max(posteriors)/sum(posteriors);
    end
    
    [histTemp,~]=histcounts(sampleTemp,linspace(0,1,23));
    histTemp=histTemp/nSamples;
    
    
    pdTemp=pdTemp(:);
    pdTemp=hist(pdTemp,linspace(0,7,22));
    pdTemp=pdTemp/(nModes^2);
    
    L=2;
    distTemp=(sum((histTemp-targetHist).^L)).^(1/L);
    distTemp=distTemp+distHistWeight*(sum((distHist-pdTemp).^L)).^(1/L);
    distTemp=distTemp/(1+distHistWeight);
    
%         distTemp=sum(abs(histTemp-targetHist))+distHistWeight*sum(abs(distHist-pdTemp));
%         distTemp=distTemp/(22+22*distHistWeight);
    
    %     distTemp=1-dot(histTemp,targetHist)/(norm(histTemp)*norm(targetHist));
    
    if distTemp<scoreBest
        scoreBest=distTemp;
        meansBest=meansTemp;
        pdBest=pdTemp;
        %         PDFBest=PDFtemp;
        histBest=histTemp;
        
        
            clf
    hold on
        plot(linspace(0,1,22),targetHist,'k')
        plot(linspace(0,1,22),distHist,'b')
        plot(linspace(0,1,22),histBest,'r')
        plot(linspace(0,1,22),pdBest,'g')
        drawnow;
        
    end
    
    waitbar(i/nReps,h,num2str(scoreBest));
    
    
    %     plot(hist(sampleTemp,linspace(0,1,23))/nSamples);
end
close(h);


out.targetHist=targetHist;
out.distHist=distHist;
out.scoreBest=scoreBest;
out.meansBest=meansBest;
% out.PDFBest=PDFBest;
out.histBest=histBest;
out.distHistBest=pdBest;
