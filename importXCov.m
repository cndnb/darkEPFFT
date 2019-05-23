function [Z,X,freqVal,numBlocks] = importXCov(numHours,fullLength,tH,hourLength)
	if(nargin != 4)
		error('importXCov - [ZX,t,freqVal,numBlocks] = importXCov(numHours,fullLength,time(Hours),hourLength)');
	endif

	%Initializing important variables
	omegaEarth = 2*pi*(1/86164.0916);

	%Matrix parameters
	designColumns = 2;
	numBlocks = floor(fullLength/hourLength);



	%Creating design matrix, Z = X' * X, and precalculating Z * X'
	oFreqCol = 2;

	X = zeros(2*numHours*(numBlocks),designColumns*(numBlocks));
	freqVal = zeros(numBlocks,1);

	signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
	freqVec = (2*pi).*freqVal;
	colSel = [1,1,0,0,0,0,0,0,0,0];
	timeH = hourLength.*tH;
	oFreqCol = 0;
	for count = 1:numBlocks
		freqVal(count,1) = ((count-1)+floor(-numBlocks/2))/fullLength;
		if(freqVal(count,1) == 0)
			X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = [ones(numHours,1),zeros(numHours,1);zeros(numHours,1),ones(numHours,1)];
		else
			X(((count-1)*(2*numHours)+1):(count*(2*numHours)),((count-1)*designColumns+1):(count*designColumns)) = signMat.*[createSineComponents(timeH,freqVec(count,1),ones(numHours,3),colSel);fliplr(createSineComponents(timeH,freqVec(count,1),ones(numHours,3),colSel))];
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
%! [Z,X,freqVal,numBlocks] = importXCov(numHours,rows(fData),tH);
%! signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
%! cS = [1,1,0,0,0,0,0,0,0,0];
%! for count = 1:numBlocks
%! 	littleX = signMat.*[createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS);fliplr(createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS))];
%! 	assert(Z(2*count-1:2*count,2*count-1:2*count), inv(littleX'*littleX),2*eps);
%! endfor
