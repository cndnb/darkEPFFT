%Initializing design matrix (very large) 
%Initializing important variables
omegaEarth = 2*pi*(1/86164.0916);
hourLength = 4096;
omegaEarthHr = omegaEarth*hourLength; %(hourLength s / 1 division)
designColumns = 6;
numHours = rows(divHours);
fullLength = numHours*hourLength;
freqArray = (0:(fullLength/2))' ./ (fullLength);
numFreq = rows(freqArray);

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
disp('done');

%Resorts data so that each column is a frequency fit
disp('Sorting into column vectors');
fflush(stdout);
shortX = ones(numHours*(hourLength/2 + 1),numFreq,designColumns); 
for count = 1:numFreq
  shortX(:,count,1) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,1),numHours*(hourLength/2 + 1),1);
  shortX(:,count,2) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,2),numHours*(hourLength/2 + 1),1);
  shortX(:,count,3) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,3),numHours*(hourLength/2 + 1),1);
  shortX(:,count,4) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,4),numHours*(hourLength/2 + 1),1);
  shortX(:,count,5) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,5),numHours*(hourLength/2 + 1),1);
  shortX(:,count,6) = reshape(X(:,(hourLength/2 + 1)*(count-1) + 1:(hourLength/2 + 1)*count,6),numHours*(hourLength/2 + 1),1);
endfor
disp('done');
fflush(stdout);

reShortX = real(shortX);
imShortX = imag(shortX);

%Initializes the weight array from the measured fft values
sigmaW = ones(numHours*((hourLength/2) + 1),1);
sigmaW = abs(reshape(compOut,rows(sigmaW),1));
sigmaW = diag(sigmaW);


disp('matrix inversions');
fflush(stdout);
%BETA = inv (Z) * X' * W * Y, Z = X' * W * X => BETA = (re/im)ZX * Y
%Real Components
reZX(:,:,1) = inv(reShortX(:,:,1)' * sigmaW * reShortX(:,:,1)) * reShortX(:,:,1)' * sigmaW;
reZX(:,:,2) = inv(reShortX(:,:,2)' * sigmaW * reShortX(:,:,2)) * reShortX(:,:,2)' * sigmaW;
reZX(:,:,3) = inv(reShortX(:,:,3)' * sigmaW * reShortX(:,:,3)) * reShortX(:,:,3)' * sigmaW;
reZX(:,:,4) = inv(reShortX(:,:,4)' * sigmaW * reShortX(:,:,4)) * reShortX(:,:,4)' * sigmaW;
reZX(:,:,5) = inv(reShortX(:,:,5)' * sigmaW * reShortX(:,:,5)) * reShortX(:,:,5)' * sigmaW;
reZX(:,:,6) = inv(reShortX(:,:,6)' * sigmaW * reShortX(:,:,6)) * reShortX(:,:,6)' * sigmaW;

%Imaginary components
imZX(:,:,1) = inv(imShortX(:,:,1)' * sigmaW * imShortX(:,:,1)) * imShortX(:,:,1)' * sigmaW;
imZX(:,:,2) = inv(imShortX(:,:,2)' * sigmaW * imShortX(:,:,2)) * imShortX(:,:,2)' * sigmaW;
imZX(:,:,3) = inv(imShortX(:,:,3)' * sigmaW * imShortX(:,:,3)) * imShortX(:,:,3)' * sigmaW;
imZX(:,:,4) = inv(imShortX(:,:,4)' * sigmaW * imShortX(:,:,4)) * imShortX(:,:,4)' * sigmaW;
imZX(:,:,5) = inv(imShortX(:,:,5)' * sigmaW * imShortX(:,:,5)) * imShortX(:,:,5)' * sigmaW;
imZX(:,:,6) = inv(imShortX(:,:,6)' * sigmaW * imShortX(:,:,6)) * imShortX(:,:,6)' * sigmaW;

disp('done');
fflush(stdout);
  
