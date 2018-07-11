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

%Creating design matrix, Z = X' * X, and precalculating Z * X'
preT = cell2mat(divHours(:,1));
t = preT(:,1);
pSort = ones((rows(t)/2)+1,numFreq*designColumns);

for count = 2:numFreq
  pX = ones(rows(t),designColumns)
  pX(:,1) = sin((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t);
  pX(:,2) = cos((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t);
  pX(:,3) = sin((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t).*sin(omegaEarth.*t);
  pX(:,4) = cos((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t).*sin(omegaEarth.*t);
  pX(:,5) = sin((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t).*cos(omegaEarth.*t);
  pX(:,6) = cos((2*pi).*freqArray(1:ceil(rows(freqArray/2)),:).*t).*cos(omegaEarth.*t);
  pB = fft(pX);
  pB = pB(1:((rows(partOne)/2)+1),:);
  pSort(:,(designColumns*(count-1) + 1):designColumns*count) = pB;
endfor

partOne(:,1) = 1;
partOne(:,2) = sin(omegaEarth.*t);
partOne(:,3) = cos(omegaEarth.*t);


partTwo(:,:,1) = sin((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t);
partTwo(:,:,2) = cos((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t);
partTwo(:,:,3) = sin((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t).*sin(omegaEarth.*t);
partTwo(:,:,4) = cos((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t).*sin(omegaEarth.*t);
partTwo(:,:,5) = sin((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t).*cos(omegaEarth.*t);
partTwo(:,:,6) = cos((2*pi).*freqArray(ceil(rows(freqArray/2))+1:end,:).*t).*cos(omegaEarth.*t);

%Converts to fft amplitudes from time series
pSort = [fft(partOne)(1:((rows(partOne)/2)+1),:),fft(partTwo)(1:((rows(partOne)/2)+1),:)]; %Since input is real, data is symmetric

disp('sorting into chunks');
X = ones(numHours,numFreq*(hourLength/2 + 1),designColumns); %Sorts data to be in chunks of (days x frequencies)
numHours
for count = 1:numHours
  count
  fflush(stdout);
  for freq = 1:numFreq
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,1) = pX(hourLength*(count-1) + 1:hourLength*count,freq,1)';
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,2) = pX(hourLength*(count-1) + 1:hourLength*count,freq,2)';
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,3) = pX(hourLength*(count-1) + 1:hourLength*count,freq,3)';
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,4) = pX(hourLength*(count-1) + 1:hourLength*count,freq,4)';
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,5) = pX(hourLength*(count-1) + 1:hourLength*count,freq,5)';
    X(count,(hourLength/2 + 1)*(freq-1) + 1:(hourLength/2 + 1)*freq,6) = pX(hourLength*(count-1) + 1:hourLength*count,freq,6)';
  endfor
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
  