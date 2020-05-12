function rootgrid=add_rootgrids(root)
%%% add grid-axes on top of axes
rootgrid=axes;% create axes
set(rootgrid,'position',get(root,'position'),'color','none','ydir','reverse');% position axes on top of axes passed as input
hold on

subplot(rootgrid)
A=[1;1]*(3:11)+0.5;
B=(mod((1:length(A(:))),4)/4>=0.5)*(50)+4.5;
plot(A(:),B(:),'color',[1 1 1]*0.5)% plot vertical lines (connected, repeated)
B=[1;1]*(0:(54));
A=~(mod((1:length(B(:))),4)/4>=0.5)*3.5+(mod((1:length(B(:))),4)/4>=0.5)*11.5;
plot(A(:),B(:)+0.5,'color',[1 1 1]*0.5)% plot horizontal lines (connected, repeated)
xlim([1 14])
ylim([length(B(:))/2-30 length(B(:))/2+3])
set(gca,'xtick',[],'ytick',[])