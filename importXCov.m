%Initializing design matrix (very large) 
%Initializing important variables
omegaEarth = 2*pi*(1/86164.0916);
hourLength = 4096;
omegaEarthHr = omegaEarth*hourLength; %(3600s / 1 division)
degSeattleLat = 47.6593743;
degSeattleLong = -122.30262920000001;
degCompassDir = 30;
%%Defining the X vector at January 1st 2000 00:00 UTC
%%Using the website https://www.timeanddate.com/worldclock/sunearth.html
%%At the time Mar 20 2000 07:35 UT
%%80*24*3600 + 7*3600 + 35*60 = 6939300 seconds since January 1, 2000 00:00:00 UTC
%%At the vernal equinox, longitude is equal to zero, so z=0;
vernalEqLong = 68.1166667;
%
%%Prepares seattleLat in terms of equatorial cordinates at January 1, 2000 00:00:00 UTC
%%This is the angle of seattleLat from the X vector
%%Additionally converts all angles to radians
seattleLong = ((pi/180)*(degSeattleLong + vernalEqLong)-omegaEarth*6939300);
seattleLat = (pi/180)*degSeattleLat;
compassDir = (pi/180)*degCompassDir;
startTime = 0;

%Matrix parameters
designColumns = 2;
numHours = rows(divHours);
fullLength = numHours*hourLength;
numBlocks = floor(fullLength/hourLength);



%Creating design matrix, Z = X' * X, and precalculating Z * X'
t=(1:numHours)';
oFreqCol = 2;
dirVal = preCalcComponents(t,seattleLat,seattleLong,compassDir,startTime);


X = zeros(2*numHours*(numBlocks),designColumns*(numBlocks));
freqVal = zeros(numBlocks,1);

signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
oFreqCol = 0;
for count = 1:numBlocks
	freqVal(count,1) = ((count-1)+floor(-numBlocks/2))/fullLength;
	if(freqVal(count,1) == 0)
		X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = [ones(numHours,1),zeros(numHours,1);zeros(numHours,1),ones(numHours,1)];
	else
		X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = signMat.*[createSineComponents(hourLength.*t,2*pi*(freqVal(count,1)),ones(numHours,3),[1,1,0,0,0,0,0,0,0,0]);fliplr(createSineComponents(hourLength.*t,2*pi*(freqVal(count,1)),ones(numHours,3),[1,1,0,0,0,0,0,0,0,0]))];
	endif
endfor

Z = inv(X' * X);
ZX = Z * X';
