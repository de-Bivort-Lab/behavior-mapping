function plotBIC(jobTag)

% plotBIC(jobTag)
% Plot BIC curves for all available GMM (independent or co-fit) results
%
% Inputs:
% jobTag [string]: folder with GMM results


% Parse results by fly/k
files=dir(sprintf('~/results/%s/%s_*.mat',jobTag,jobTag));
scoresByFlyByK=containers.Map();
for iFile=1:length(files)
    file=files(iFile);
    tokens=regexp(file.name,sprintf('^%s_([^_]+?)_(.+)_(\\d+)\\.mat$',jobTag),'tokens');
    flyName=tokens{1}{2};
    k=str2double(tokens{1}{3});
    assert(k>0);
    vars=load(sprintf('~/results/%s/%s',jobTag,file.name));
    gmm=vars.gmm;

    if ~isKey(scoresByFlyByK,flyName)
        scoresByFlyByK(flyName)=containers.Map('KeyType','double','ValueType','any');
    end
    scoresByK=scoresByFlyByK(flyName);
    scoresByK(k)=gmm.BIC; %#ok<NASGU>
end

% Plot all results
flyNames=keys(scoresByFlyByK);
NFlies=length(flyNames);
plotv=min(4,round(sqrt(NFlies)));
ploth=min(4,ceil(NFlies/plotv));
numPlots=ceil(NFlies/(ploth*plotv));

for iPlot=1:numPlots
    figure;
    for iSubPlot=1:min(plotv*ploth,NFlies-(iPlot-1)*plotv*ploth)
        subplot(plotv,ploth,iSubPlot);
        iFly=plotv*ploth*(iPlot-1) + iSubPlot;
        flyName=flyNames{iFly};
        
        % Grab scores for this fly and plot them
        scoresByK=scoresByFlyByK(flyName);
        K=sort(cell2mat(keys(scoresByK)));
        bics=[];
        for k=K
            bics(end+1)=scoresByK(k); %#ok<AGROW>
        end
        % Now plot all of our values
        plot(K,bics,'LineWidth',2);
        title(sprintf('%s %s - BIC vs K',jobTag,flyName));
    end
end
