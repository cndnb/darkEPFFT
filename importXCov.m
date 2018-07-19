%Initializing design matrix (very large) 
%Initializing important variables
omegaEarth = 2*pi*(1/86164.0916);
hourLength = 4096;
omegaEarthHr = omegaEarth*hourLength; %(3600s / 1 division)
designColumns = 6;
numHours = rows(divHours);
fullLength = numHours*hourLength;
numBlocks = floor(fullLength/hourLength);

%Creating design matrix, Z = X' * X, and precalculating Z * X'
oFreqCol = 3;
X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - oFreqCol);
X(1:numHours,1:oFreqCol) = [ones(numHours,1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];
for count = 2:numBlocks
	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - oFreqCol:(count*designColumns) - oFreqCol) = ...
		[sin(((count*hourLength)/(fullLength)).*t),... 
		 cos(((count*hourLength)/(fullLength)).*t),...   
		 sin(((count*hourLength)/(fullLength)).*t).*sin(omegaEarthHr.*t),... 
		 cos(((count*hourLength)/(fullLength)).*t).*sin(omegaEarthHr.*t),...   
		 sin(((count*hourLength)/(fullLength)).*t).*cos(omegaEarthHr.*t),... 
		 cos(((count*hourLength)/(fullLength)).*t).*cos(omegaEarthHr.*t)];   
endfor

Z = inv(X' * X);
ZX = Z * X';
