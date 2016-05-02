function plotFrameNormalization(flyNames)

% plotFrameNormalization(flyName)
% Figures illustrating our frame normalization procedure
%
% Inputs:
% flyNames [NFlies x 1 string]: flies used as examples of our bimodal variance distribution
%
% Figure 1C: plotFrameNormalization({'f37_1','f37_2','f38_1','f39_1'})

% Plot each of our flies
NFlies=length(flyNames);
plotv=min(4,round(sqrt(NFlies)));
ploth=min(4,ceil(NFlies/plotv));
figure;
for iFly=1:NFlies
    flyName=flyNames{iFly};
    subplot(plotv,ploth,iFly);
    % Load wavelet data for the fly, plot variances
    vars=load(sprintf('~/data/cfs/cfsdata_%s.mat',flyName));
    cfsdata=double(vars.cfsdata);
    variances=var(cfsdata,[],2);
    hist(log(variances),1000);
    % Draw variance threshold
    [~,~,varThreshold]=loadVarThreshold(flyName);
    ylims=ylim;
    line([log(varThreshold) log(varThreshold)],[ylims(1) ylims(2)],'Color','r','LineWidth',1);
    xlabel('log of frame variance');
    ylabel('count');
    title(sprintf('%s - %d frames',flyName,size(cfsdata,1)));
end

% Create example data: 10s of data at 100 Hz, white noise background, 5 Hz and 20 Hz periodic bursts
t=linspace(0,10,1000)';
y=zeros(length(t),1);
window=ones(200,1);
window(1:50)=1-cos((0:49)*pi/2/49).^2;
window(151:200)=cos((0:49)*pi/2/49).^2;
y(201:400)=sin(5*2*pi*t(201:400)) .* window;
y(601:800)=sin(20*2*pi*t(601:800)) .* window;
y=y+0.2*sin(2*2*pi*t);
%y=awgn(y,30);

% Take wavelet transform, then frame-normalize
parameters=tsneSetParameters();
parameters.pcaModes=1;
Y=findWavelets(y,parameters.pcaModes,parameters);

YAmps=sum(Y,2);
YNorm=bsxfun(@rdivide,Y,YAmps);

hfig=figure;
subplot(311);
imagesc(Y');
colorbar;
title('Raw wavelet data');
v=caxis;
ax1=gca();

subplot(312);
imagesc(YNorm');
v=caxis;
colorbar;
title('Frame-normalized wavelet data');
ax2=gca();

caxis(ax1,v);

subplot(313);
plot(YAmps);
title('Sum of wavelet magnitudes by frame');
ax3=gca();

linkaxes([ax1 ax2 ax3],'x');
setFigureZoomMode(hfig,'h');

