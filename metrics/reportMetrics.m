function reportMetrics(jobTags,pathResult)

% reportMetrics(jobTags)
% Produce a report combining metrics from the given jobs, metrics must first be computed by gatherMetrics()
%
% Inputs:
% jobTags [NJobs x 1 string]: folders where metrics are stored
% pathResult [string]: path to file where we save metrics
%
% Results:
% metrics [NFlies x NMetrics x NMethods x NJobs]: values for each of our metrics
% meanCVs [NMetrics x NMethods]: coefficient of variation across jobs, mean taken across flies
% flies [NFlies x 1 string]: names for each fly
% metricNames [NMetrics x 1 string]: names for each metric
% methodNames [NMethods x 1 string]: names for each of our mapping methods
% jobTags [NJobs x 1 string]: names for each job we processed
%
% Figure 2: reportMetrics(sprintfc('tmRound%d',1:5),'~/results/all_metrics.mat')

% Load our first set of results to get metric names
flies=allFlies()';
NFlies=length(flies);
vars=load(sprintf('~/results/%s/metrics.mat',jobTags{1}));
metricNames=fieldnames(vars.metricsByFly(flies{1}));
NMetrics=length(metricNames);
methodNames=fieldnames(vars.metricsByFly(flies{1}).(metricNames{1}));
NMethods=length(methodNames);

% Gather all of our metrics
metrics=zeros(NFlies,NMetrics,NMethods,length(jobTags));

for iJob=1:length(jobTags)
    vars=load(sprintf('~/results/%s/metrics.mat',jobTags{iJob}));
    metricsByFly=vars.metricsByFly;
    
    for iFly=1:NFlies
        flyMetrics=metricsByFly(flies{iFly});
        
        for iMetric=1:NMetrics
            metricValues=flyMetrics.(metricNames{iMetric});
            
            for iMethod=1:NMethods
                metrics(iFly,iMetric,iMethod,iJob)=metricValues.(methodNames{iMethod});
            end
        end
    end
end

% Compute coefficient of variation across jobs, then take mean across flies
meanCVs=zeros(NMetrics,NMethods);
for iMetric=1:NMetrics
    for iMethod=1:NMethods
        cvs=zeros(NFlies,1);
        for iFly=1:NFlies
            metricValues=squeeze(metrics(iFly,iMetric,iMethod,:));
            cv=std(metricValues,1)/mean(metricValues);
            cvs(iFly)=cv;
        end
        meanCVs(iMetric,iMethod)=mean(cvs);
    end
end
        
save(pathResult,'metrics','meanCVs','flies','metricNames','methodNames','jobTags');
