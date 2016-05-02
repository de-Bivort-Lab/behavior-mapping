function plotMetrics(jobTags)

% plotMetrics(jobTag)
% Plot metrics for the given jobs, metrics must first be computed by gatherMetrics()
%
% Inputs:
% jobTags [NJobs x 1 string]: folders where metrics are stored, we take the mean across all of the given jobs
%
% Figure 2: plotMetrics(sprintfc('tmRound%d',1:5))

% Load metrics for the given jobs
NJobs=length(jobTags);
metricsByFly=cell(NJobs,1);
for iJob=1:NJobs
    jobTag=jobTags{iJob};
    vars=load(sprintf('~/results/%s/metrics.mat',jobTag));
    metricsByFly{iJob}=vars.metricsByFly;
end

% Allocate a color for each fly
[flies,nanFlies,~,flyPrefixes]=allFlies();
cols=colorcube(length(flyPrefixes));
colsByFly=containers.Map();
for iFly=1:length(flies)
    flyName=flies{iFly};
    tokens=strsplit(flyName,'_');
    flyPrefix=tokens{1};
    colsByFly(flies{iFly})=cols(find(strcmp(flyPrefixes,flyPrefix)),:); %#ok<FNDSB>
end


% One subplot for each metric
metricNames=fieldnames(metricsByFly{1}(flies{1}));

figure;
for iMetric=1:length(metricNames)
    subplot(2,4,iMetric);
    title(metricNames{iMetric});
    hold on;
    
    % We define our mapping method order here
    methods={'p2g','p2w','t2g','t2w','p20g','r'};
    namesByMethod=containers.Map();
    namesByMethod('p2g')='PCA2 GMM';
    namesByMethod('p2w')='PCA2 watershed';
    namesByMethod('t2g')='t-SNE2 GMM';
    namesByMethod('t2w')='t-SNE2 watershed';
    namesByMethod('p20g')='PCA20 GMM';
    namesByMethod('r')='random';
    
    % Plot points and connecting lines for each fly
    for flyNameCell=flies
        flyName=flyNameCell{1};
        % WT/NAN determines color
        if any(strcmp(flyName,nanFlies))
            color='r';
        else
            color='b';
        end
        
        % Grab the current metric values for this fly and unpack them, take the mean across jobs
        meanvals=zeros(length(methods),1);
        for iJob=1:NJobs
            flyMetrics=metricsByFly{iJob}(flyName);
            metricValues=flyMetrics.(metricNames{iMetric});
            vals=zeros(length(methods),1);
            for iMethod=1:length(methods)
                vals(iMethod)=metricValues.(methods{iMethod});
            end
            meanvals=meanvals+vals;
        end
        clear vals
        meanvals=meanvals/NJobs;
        
        % Use the value as x, the metric determines y, plot points
        scatter(meanvals,1:length(meanvals),color);

        % Draw lines connecting values from each fly
        lineColor=colsByFly(flyName);
        for i=1:length(meanvals)-1
            line([meanvals(i) meanvals(i+1)],[i i+1],'Color',lineColor);
        end
    end
    
    % Set ticks
    set(gca,'YTick',1:6);
    tickLabels=cell(length(methods),1);
    for iMethod=1:length(methods)
        tickLabels{iMethod}=namesByMethod(methods{iMethod});
    end
    set(gca,'YTickLabel',tickLabels);
    
    if strcmp(metricNames{iMetric},'xCounts') || strcmp(metricNames{iMetric},'shortCounts') || strcmp(metricNames{iMetric},'exitStates')
        set(gca,'XScale','log');
    end
end
