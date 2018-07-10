%Initializing design matrix (very large) %UPDATE%
%Initializing important variables
omegaEarth = 2*pi*(1/86164.0916);
hourLength = 4096;
omegaEarthHr = omegaEarth*hourLength; %(hourLength s / 1 division)
designColumns = 4;
numHours = rows(divHours);
fullLength = numHours*hourLength;
freqArray = (0:(fullLength/2))' ./ (fullLength);
numFreq = rows(freqArray);

%Creating design matrix, Z = X' * X, and precalculating Z * X'
t = (1:hourLength)';
X = cell(designColumns,numFreq,2); %Makes an FFT array over the entire dataset

numFreq
for freq = 1:numFreq
  freq
  fflush(stdout);
  reAccumHours = ones(numHours,((hourLength/2) + 1),designColumns);
  imAccumHours = ones(numHours,((hourLength/2) + 1),designColumns);
  for count = 1:numHours
    hour = divHours{count,2};
    phaseFactor = 0;
    if (freqArray(freq) != 0)
      phaseFactor = ((hour*hourLength)/freqArray(freq));
    endif
    tS = [sin(2*pi*freqArray(freq).*t + phaseFactor),...
          cos(2*pi*freqArray(freq).*t + phaseFactor),...
          sin(2*pi*freqArray(freq).*t + phaseFactor).*cos(omegaEarth.*t + phaseFactor),...
          cos(2*pi*freqArray(freq).*t + phaseFactor).*cos(omegaEarth.*t + phaseFactor)];
    pX = fft(tS);
    assert(pX(2:(rows(pX)/2),:),conj(flip(pX((rows(pX)/2) + 2:end,:))));
    pX = pX(1:(rows(pX)/2) + 1,:);
    for dC = 1:designColumns
      reAccumHours(count,:,dC) = real(pX(:,dC))';
      imAccumHours(count,:,dC) = imag(pX(:,dC))';
    endfor
  endfor
  for dC = 1:designColumns
    X{dC,freq,1} = reAccumHours(:,:,dC); %numHours x (hourLength/2 + 1) matrix into {dC,freq}
    X{dC,freq,2} = imAccumHours(:,:,dC);
  endfor
endfor

%Z*X' calculation for each frequency
ZX = cell(size(X));
for freq = 1:columns(X)
  for count = 1:rows(X)
    ZX{count,freq,1} = (X{count,freq,1}')*(X{count,freq,1})*(X{count,freq,1}');
    ZX{count,freq,2} = (X{count,freq,2}')*(X{count,freq,2})*(X{count,freq,2}');
  endfor
endfor


%X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - 3);
%X(1:numHours,1:3) = [ones(numHours,1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];
%for count = 2:numBlocks
%	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - 3:(count*designColumns) - 3) = ...
%		[sin(((count*3600)/(fullLength)).*t),... 
%		 cos(((count*3600)/(fullLength)).*t),...   
%		 sin(((count*3600)/(fullLength)).*t).*sin(omegaEarthHr.*t),... 
%		 cos(((count*3600)/(fullLength)).*t).*sin(omegaEarthHr.*t),...   
%		 sin(((count*3600)/(fullLength)).*t).*cos(omegaEarthHr.*t),... 
%		 cos(((count*3600)/(fullLength)).*t).*cos(omegaEarthHr.*t)];   
%endfor
%
%Z = inv(X' * X);
%ZX = Z * X';
