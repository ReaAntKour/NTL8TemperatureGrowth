function out=cell_division(rootHalf)
% Function is called by rootSim
% Simulates cell division
% Divisions occur synchronously in the "bottom" 32 cells (division zone)
% Cells above that zone get pushed up the root by 32 rows
% rootHalf is described in rootSim: matrix of dimensions: rootLength x rootWidth
% Function takes the matrix of the root before division as input
% returns the matrix of the root after division as output
tmp=rootHalf;
for i=length(rootHalf(rootHalf(:,1)>=0,1)):-1:1
	r=32+i;
	if i<=32% for cells in division zone
		rootHalf(2*(i-1)+1,:)=tmp(i,:)/2;% split the concentration between two adjacent cells at new positions
		rootHalf(2*i,:)=tmp(i,:)/2;
	elseif r<=length(rootHalf(:,1))% for other cells
		rootHalf(r,:)=tmp(i,:);% move the concentration value to the new cell position, 32 rows up
	end
	% if root becomes too long for container (after division, length would
	% be >rootLength), all cells that would be pushed beyond that region
	% are ignored. This is the case r>length(rootHalf(:,1))
end
out=rootHalf;% return new root concentration matrix
