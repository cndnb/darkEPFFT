%Initializing design matrix (very large) 
%Initializing important variables
omegaEarth = 2*pi*(1/86164.0916);
hourLength = 4096;
omegaEarthHr = omegaEarth*hourLength; %(3600s / 1 division)
designColumns = 6;
numHours = rows(divHours);
fullLength = numHours*hourLength;
numBlocks = floor(fullLength/hourLength);

seattleLat = (pi/180)*47.6593743;
compassDir = pi/6;
phi = omegaEarthHr.*t;

%Creating design matrix, Z = X' * X, and precalculating Z * X'
oFreqCol = 3;
X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - oFreqCol);
X(1:numHours,1:oFreqCol) = [ones(numHours,1)*cos(seattleLat)*cos(compassDir),(-cos(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*sin(phi)),(sin(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*cos(phi))];
for count = 2:numBlocks
	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - oFreqCol:(count*designColumns) - oFreqCol) = ...
		[sin(((count*hourLength)/(fullLength)).*t)*cos(seattleLat)*cos(compassDir),... 
		 cos(((count*hourLength)/(fullLength)).*t)*cos(seattleLat)*cos(compassDir),...   
		 sin(((count*hourLength)/(fullLength)).*t).*(-cos(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*sin(phi)),... 
		 cos(((count*hourLength)/(fullLength)).*t).*(-cos(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*sin(phi)),...   
		 sin(((count*hourLength)/(fullLength)).*t).*(sin(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*cos(phi)),... 
		 cos(((count*hourLength)/(fullLength)).*t).*(sin(phi)*sin(compassDir)-sin(seattleLat)*cos(compassDir)*cos(phi))];   
endfor

Z = inv(X' * X);
ZX = Z * X';
