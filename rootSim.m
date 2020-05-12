function rootSim()
%% parameters
%%% for root
rootLength=900;% length of "rootHalf" matrix and maximum length of root
rootWidth=4;% width of "rootHalf" matrix

%%% for cold treatment
pregrowth=10;% day of transfer from warm to cold (9 days growth in warm before cold)
vernalization=42;% duration of cold (vernalization) treatment in days
timepoint=[9,16,23,37,51,58];% timepoints (days) at which code plots the model
timepointNames={'NV','1W','2W','4W','6W','6WT7'};% same timepoints, described as in figure 4

%%% for production of NTL8 protein
amountAdded=1;% production rate of NTL8 protein is 1/day

%%% for visualisation
latTipLength=4;% length of lateral root cap, shown as visual reference. not part of "rootHalf"
brightfieldGFP% call file brightfieldGFP.m which defines the 3 column matrix "brightfieldGFPmap"
amountMin=exp(-8);% minimum value of colormap. value of root with no detectable NTL8
amountMax=3;% maximum value of colormap
ylim2=0.04*32/0.0274;% y-axis limit for concentration plot


%% Setup simulation
% amount produced in each cell (only in 3 of 4 columns and only in bottom row):
produce=[amountAdded/3,amountAdded/3,amountAdded/3,0;zeros(rootLength-1,rootWidth)];

% starting concentrations at t=0, when root is 64 rows of cells long (not including lateral root cap):
firstLine=[ones(2,1)*1;ones(2,1)*1/2;ones(4,1)*1/4;ones(8,1)*1/8;ones(16,1)/16;ones(32,1)/32]*produce(1,:)/7*2;


%%% root definition
% matrix of dimensions rootLength x rootWidth that gives the concentrations
% of NTL8 protein in each cell of the simulated half-root. Negative values
% used for "outside root", positive values are concentration in the cell
rootHalf=[firstLine;-1*ones(rootLength-length(firstLine(:,1)),rootWidth)];

% matrix of lateral root cap (double width as in the visualization the
% half-root is mirrored)
latTip=zeros(latTipLength,2*rootWidth)-1;
% QC cells: assumed not to divide or produce. sit under stele initial as
% reference point
latTip(end,rootWidth+(0:1))=amountAdded*[1 1];


%%% initiate variables
t=0;
time=0;
concCell=rootHalf(rootHalf(:,1)>0,:);% matrix of cells (excluding negative values of non-root)
conc=mean(concCell(:))*32/0.0274;% concentration in root, normalised to the growth rate of the ODE model for comparison


%% Run simulation
j=1;% counter for when to divide (value always 1 in warm, 0-6 in cold)
while t<pregrowth+vernalization+12% run simulation until 12 days after vernalization
	t=t+1;% progress time
	cold=(t>=pregrowth)&&(t<(pregrowth+vernalization));% logical: is it cold now?
	
	%% Produce protein
	%%% Change division frequency (once every 7 days) to simulate transfer to cold
	if t==(pregrowth+vernalization)% after the end of the cold, set back to 1
		j=1;
	elseif (t==pregrowth)||(j==0)% at the start of the cold set to 6 and also reset after 7 days
		j=6;
	elseif cold% progress during cold
		j=j-1;
	end

	%%% Apply increase due to production
	% produce only inside the root (positive "rootHalf") and only in
	% initials, according to matrix "produce"
	rootHalf=produce.*(rootHalf>0)+rootHalf;

	%% Cell Division
	if j==1% only divide if j is 1 (always in warm, once every 7 days in cold)
		rootHalf=cell_division(rootHalf);% function defined in file cell_division.m
	end

	%% measure and save concentration
	time(t+1)=t;
	concCell=rootHalf(rootHalf(:,1)>0,:);% matrix of cells (excluding negative values of non-root)
	conc(t+1)=mean(concCell(:))*32/0.0274;% concentration in root, normalised to the growth rate of the ODE model for comparison

	%% make and draw image of root
	if ismember(t,timepoint)
		%% Setup plots
		%%% Prepare figures
		fig=find(t==timepoint);
		figure%(fig)

		backG=axes;% background to concentration plot, showing red for warm and blue for cold
		set(backG,'position',[0.55 0.12 0.4 0.34])
		fill([pregrowth-1 pregrowth-1 pregrowth+vernalization-1 pregrowth+vernalization-1],[0 ylim2 ylim2 0],[0.8 0.8 1],'edgecolor','none')
		hold on
		fill([pregrowth+vernalization+12 pregrowth+vernalization+12 pregrowth+vernalization-1 pregrowth+vernalization-1],[0 ylim2 ylim2 0],[1 0.8 0.8],'edgecolor','none')
		fill([pregrowth-1 pregrowth-1 0 0],[0 ylim2 ylim2 0],[1 0.8 0.8],'edgecolor','none')
		xlim([0 pregrowth+vernalization+12])
		ylim([0 ylim2])
		set(gca,'xtick',[],'ytick',[])

		foreG=axes;% create axes for concentration plot
		set(foreG,'position',get(backG,'position'))

		rootTip=axes;% create axes for zoomed in root tip plot
		set(rootTip,'position',[0.65 0.51 0.22 0.4])
		
		% calls add_rootgrids.m which creates axes above the "rootTip" axes
		% and draws a grid separating the cells:
		rootgrid=add_rootgrids(rootTip);
		colormap(brightfieldGFPmap)

		rootGFP=axes;% create axes for whole root
		set(rootGFP,'position',[0.27 0.12 0.18 0.8])

		%% draw plots
		%%% make and draw image of root
		% define new matrix by combining the "rootHalf" matrix with a
		% mirror image of itself and the lateral root cap:
		rootIm=[amountMin+latTip;rootHalf(rootHalf(:,1)>=0,end:-1:1),rootHalf(rootHalf(:,1)>=0,:)];
		rootIm(rootIm<amountMin)=amountMin;% set minimum of image to very low
		rootIm(end,1)=amountMax;% set maximum of image to define colormap range
		
		subplot(rootGFP)
		fill([-10 -10 10+2*length(rootHalf(1,:)) 10+2*length(rootHalf(1,:))],[0 rootLength+10 rootLength+10 0],0.9*[1 1 1],'edgecolor','none')% draw background (non-root)
		hold on
		imagesc(rootIm(end:-1:1,:));% draw whole root
		colorbar% draw colorbar
		set(gca,'xtick',[],'ytick',[],'YDir','reverse')
		hold off
		title(timepointNames{fig});
		xlim([-5 5+2*length(rootHalf(1,:))])
		ylim([0 rootLength+10])

		% print the new maximum value of the colormap if an unexpectedly
		% high concentration value appears in rootHalf:
		if max(rootHalf(:))>amountMax
			max(rootHalf(:))
		end
		
		subplot(rootTip)
		fill([-10 -10 10+2*length(rootHalf(1,:)) 10+2*length(rootHalf(1,:))],[0 rootLength+10 rootLength+10 0],0.9*[1 1 1],'edgecolor','none')% draw background (non-root)
		hold on
		imagesc(rootIm(end:-1:1,:));% draw whole root
		xlim([-2 11])% x-axis zoom in
		ylim([sum(rootHalf(:,1)>0)-25 sum(rootHalf(:,1)>0)+8])% y-axis zoom in
		set(gca,'xtick',[],'ytick',[],'YDir','reverse')
		title('Root Tip')


		subplot(foreG)
		plot(time,conc,'k')% plot concentration over time up to current time
		set(foreG,'color','none')
		xlim([0 pregrowth+vernalization+12])
		ylim([0 ylim2])
		ylabel('Plant average concentration')
		xlabel('Time from germination (days)')
		%saveas(gcf,['compModel_',int2str(t),'.png'])% save the figure
	end
end