m1All_2=m1All>10^-1.8;
m1All_2=m1All_2+m1All_2’;
m1All(boolean(eye(41,41)))=0;
G=graph(m1All_2>0);
graphEdgeClassPlotter(G,m1All>10^-1.8,score(:,1:3))