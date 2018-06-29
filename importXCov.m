
X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - 2);
X(1:numHours,1:3) = [ones(numHours,1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];
for count = 2:numBlocks
	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - 2:(count*designColumns) - 2) = ...
		[ones(numHours,1),...
		 sin(omegaEarthHr.*t),...
		 cos(omegaEarthHr.*t),...
		 sin(((count*3600)/(2*runLength)).*t),... %Needs to be correct freq units
		 cos(((count*3600)/(2*runLength)).*t)];   %Needs to be correct freq units
endfor

Z = inv(X' * X);
ZX = Z * X';
