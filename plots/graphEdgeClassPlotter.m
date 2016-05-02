function out=graphEdgeClassPlotter(G,connect,Vcolors)

Vcolors=Vcolors-repmat(min(Vcolors),size(Vcolors,1),1);
Vcolors=Vcolors./repmat(max(Vcolors),size(Vcolors,1),1);

connectTemp=connect(:);
connectTemp(connectTemp==0)=[];
classList=unique(connectTemp);
numClasses=length(classList);

colors=rand(numClasses,3)*0.7+0.15;

X=get(plot(G),'XData');
Y=get(plot(G),'YData');

% X=G(:,1);
% Y=G(:,2);

X=(X-min(X))/(max(X)-min(X))*0.8+0.1;
Y=(Y-min(Y))/(max(Y)-min(Y))*0.8+0.1;

dotSize=0.01;

figure;
hold on;

% scatter(X,Y)
set(gca,'Ytick',[]);
set(gca,'Xtick',[]);
set(gca,'position',[0 0 1 1]);

set(gcf,'position',[100 100 400 400]);

GEdges=table2array(G.Edges);

% GEdges=[];
% for i=1:size(connect,1)
%     for j=1:size(connect,1)
%         if connect(i,j)~=0
%             GEdges=[GEdges;i j];
%         end
%     end
% end

method=1;

count=0;
for i=1:size(GEdges,1)
    
    V1=GEdges(i,1);
    V2=GEdges(i,2);
    
    if connect(V1,V2)~=0
        X1=X(V1);
        Y1=Y(V1);
        X2=X(V2);
        Y2=Y(V2);
        
        theta=atan2((Y2-Y1),(X2-X1));
        R=sqrt((Y2-Y1).^2 + (X2-X1).^2)-dotSize;
        count=count+1;
        colorTemp=colors(classList==connect(V1,V2),:);
        switch method
            case 0
                annotation('arrow',[X1 X1+R*cos(theta)],[Y1 Y1+R*sin(theta)],'Color',colorTemp);
            case 1
                annotation('line',[X1 X1+R*cos(theta)],[Y1 Y1+R*sin(theta)],'Color',colorTemp);
        end
    end
    
    if connect(V2,V1)~=0
        X1=X(V2);
        Y1=Y(V2);
        X2=X(V1);
        Y2=Y(V1);
        
        theta=atan2((Y2-Y1),(X2-X1));
        R=sqrt((Y2-Y1).^2 + (X2-X1).^2)-dotSize;
        count=count+1;
        colorTemp=colors(classList==connect(V2,V1),:);
        switch method
            case 0
                annotation('arrow',[X1 X1+R*cos(theta)],[Y1 Y1+R*sin(theta)],'Color',colorTemp);
            case 1
                annotation('line',[X1 X1+R*cos(theta)],[Y1 Y1+R*sin(theta)],'Color',colorTemp);
        end
    end
    
    
end


for i=1:size(connect,1)
    
    annotation('ellipse',[X(i)-dotSize Y(i)-dotSize 2*dotSize 2*dotSize ],'Color',Vcolors(i,:));
end



