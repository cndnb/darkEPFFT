function [Z,X,freqVal,numBlocks] = importXCov(numHours,fullLength,tH,hourLength)
	if(nargin != 4)
		error('importXCov - [ZX,t,freqVal,numBlocks] = importXCov(numHours,fullLength,time(Hours),hourLength)');
	endif

	%Initializing important variables
	omegaEarth = 2*pi*(1/86164.0916);

	%Matrix parameters
	designColumns = 2;
	numBlocks = floor(fullLength/hourLength);

  %Initializes accumulation arrays
	X = zeros(2*numHours*(numBlocks),designColumns*(numBlocks));
	freqVal = zeros(numBlocks,1);
  %Assigns values to intermediate frequency array
  for count = 1:numBlocks
    freqVal(count,1) = ((count-1)+floor(-numBlocks/2))/fullLength;
  endfor
  %Creates matrix of signs to get correct LC of trig functions for angle sum identities
	signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
  %Premultiplies frequencies by 2pi
	freqVec = (2*pi).*freqVal;
  %Selects only pure sin and cos components in createSineComponents
	colSel = [1,1,0,0,0,0,0,0,0,0];
  %Multiplies hours by length of hour to match frequencies (they are 1/seconds)
	timeH = hourLength.*tH;
  %Creates direction constants to account for longitude and latitude of the pendulum on earth
	cM = ones(rows(tH),3);
	%cM = preCalcComponents(tH.*hourLength,seattleLat,seattleLong,compassDir,startTime);
	for count = 1:numBlocks
		if(freqVal(count,1) == 0)
			X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = ...
      [ones(numHours,1),zeros(numHours,1);zeros(numHours,1),ones(numHours,1)];
		else
			X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = ...
      signMat.*[createSineComponents(timeH,freqVec(count,1),cM,colSel);...
      fliplr(createSineComponents(timeH,freqVec(count,1),cM,colSel))];
		endif
	endfor

	Z = inv(X' * X);

endfunction

%!test
%! hourLength = 4096;
%! t=1:1e5; t=t';
%! fData = [t,randn(rows(t),1)];
%! numHours = floor(rows(fData)/hourLength);
%! tH = (1:numHours)';
%! [Z,X,freqVal,numBlocks] = importXCov(numHours,rows(fData),tH,hourLength);
%! signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
%! cS = [1,1,0,0,0,0,0,0,0,0];
%! for count = 1:numBlocks
%! 	littleX = signMat.*[createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS);fliplr(createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS))];
%! 	assert(Z(2*count-1:2*count,2*count-1:2*count), inv(littleX'*littleX),2*eps);
%! endfor
%!
%! ZX = Z*X'; 
%! for count = 1:rows(freqVal)
%! 	preData = exp((2*pi*freqVal(count)).*tH);
%! 	doubleData = [real(preData);imag(preData)];
%!	checkData = repmat(doubleData,numBlocks,1);
%!	BETA = ZX*checkData;
%!	expectedBETA = zeros(rows(BETA),1);
%!	expectedBETA(2*count-1:2*count,1) = ones(2,1);
%!	assert(BETA,expectedBETA);
%! endfor

