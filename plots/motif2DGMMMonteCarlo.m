function out=motif2DGMMMonteCarlo

targetHist=[0;0;0;0.000166483434898228;0.000942906180835007;...
    0.00294970650420283;0.00642936027865227;0.0111988857108718;...
    0.0164983584133379;0.0217978311158040;0.0292970849400485;...
    0.0382961895291419;0.0373962790702325;0.0371962989682527;...
    0.0377962392741922;0.0391960999880512;0.0411959010078497;...
    0.0456054622565055;0.0524947767697114;0.0649935331434522;...
    0.0935906877265712;0.422957915687389]';

nModes=100;
modeStd=10;
imSize=500;
totalPDF=zeros(imSize*3,imSize*3,nModes);
means=ceil(rand(nModes,2)*imSize+imSize);
modeImage=fspecial('gaussian',modeStd*7+1,modeStd);
% disp(max(modeImage(:)));

PDFtemp=totalPDF;
for i=1:nModes
    rowRange=(means(i,1)-modeStd*3.5):(means(i,1)+modeStd*3.5);
    colRange=(means(i,2)-modeStd*3.5):(means(i,2)+modeStd*3.5);
    PDFtemp(rowRange,colRange,i)=modeImage;
end
fh1;
imagesc(sum(PDFtemp,3));
fh1;
 plot(targetHist,'k')

nReps=400;
nSamples=30000;
numToTweak=4;
tweakRadius=10;

scoreBest=Inf;
meansBest=means;
PDFBest=PDFtemp;
histBest=[];

for i=1:nReps;
    
    PDFtemp=PDFBest;
    meansTemp=meansBest;
    tweakR=tweakRadius*(nReps-i)/nReps;
    for j=1:numToTweak
        whichToTweak=ceil(rand()*nModes);
        meansTemp(whichToTweak,1)=ceil(meansTemp(whichToTweak,1)+randn()*tweakR);
        meansTemp(whichToTweak,2)=ceil(meansTemp(whichToTweak,2)+randn()*tweakR);
        rowRange=(meansTemp(whichToTweak,1)-modeStd*3.5):(meansTemp(whichToTweak,1)+modeStd*3.5);
        colRange=(meansTemp(whichToTweak,2)-modeStd*3.5):(meansTemp(whichToTweak,2)+modeStd*3.5);
        PDFtemp(:,:,whichToTweak)=zeros(imSize*3,imSize*3,1);
        PDFtemp(rowRange,colRange,whichToTweak)=modeImage;
    end
    
    
    sampleTemp=zeros(nSamples,1);
    for j=1:nSamples
        whichMode=ceil(rand()*nModes);
        x=round(randn()*modeStd)+meansTemp(whichMode,1);
        y=round(randn()*modeStd)+meansTemp(whichMode,2);
        posteriors=squeeze(PDFtemp(x,y,:));
        posteriors=sort(posteriors);
        sampleTemp(j)=posteriors(end)/sum(posteriors);
    end
    
    [histTemp,~]=histcounts(sampleTemp,linspace(0,1,23));
    histTemp=histTemp/nSamples;
    distTemp=sqrt(sum((histTemp-targetHist).^2));

%     distTemp=1-dot(histTemp,targetHist)/(norm(histTemp)*norm(targetHist));
    
    if distTemp<scoreBest
        scoreBest=distTemp;
        meansBest=meansTemp;
        PDFBest=PDFtemp;
        histBest=histTemp;
        disp([i distTemp])
    end
    
   
    plot(histBest,'r')
    drawnow;
    
    
    %     plot(hist(sampleTemp,linspace(0,1,23))/nSamples);
end

plot(histBest,'b')

fh1;imagesc(sum(PDFtemp,3));

out.targetHist=targetHist;
out.scoreBest=scoreBest;
out.meansBest=meansBest;
out.PDFBest=PDFBest;
out.histBest=histBest;