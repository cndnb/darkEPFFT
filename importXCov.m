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
X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - 3);
X(1:numHours,1:3) = [ones(numHours,1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];
for count = 2:numBlocks
	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - 3:(count*designColumns) - 3) = ...
		[sin(((count*3600)/(fullLength)).*t),... 
		 cos(((count*3600)/(fullLength)).*t),...   
		 sin(((count*3600)/(fullLength)).*t).*sin(omegaEarthHr.*t),... 
		 cos(((count*3600)/(fullLength)).*t).*sin(omegaEarthHr.*t),...   
		 sin(((count*3600)/(fullLength)).*t).*cos(omegaEarthHr.*t),... 
		 cos(((count*3600)/(fullLength)).*t).*cos(omegaEarthHr.*t)];   
endfor

Z = inv(X' * X);
ZX = Z * X';
