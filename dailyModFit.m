function [allA,allB,freqArray] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength,freqInterval,freqVal,shortFreqArray) %UPDATE%
	if (nargin != 9)
		error('[bMA,bMB] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength,freqInterval);');
	endif
	

	freqArray = (0:(dataLength/2))' ./ (dataLength);
	freqCheck = ones(rows(freqArray),1);
	out = zeros(rows(freqArray),2);
	columns(Y)
	fflush(stdout);
	pause(3);
	for freqCount = 1:columns(Y)
		placeInd = (freqCount-1)*n+1;
		freqCount
		fflush(stdout);
		BETA = (ZX*Y(:,freqCount));
		newBETA = ones(n,2);
		for count = 1:n
			if(placeInd + (count-1) + floor(-n/2) < 1 || placeInd + (count-1) + floor(-n/2) > rows(freqArray)) 
			else
				freqCheck(placeInd+(count-1)+floor(-n/2),1) = freqVal(count) + shortFreqArray(freqCount);
				out(placeInd+(count-1)+floor(-n/2),1) = BETA(2*(count-1)+1,1);
				out(placeInd+(count-1)+floor(-n/2),2) = BETA(2*(count-1)+2,1);
			endif
		endfor
	endfor

	assert(freqCheck,freqArray,eps);

	%Sets up return arrays
	allA = [freqArray,out(:,1)];
	allB = [freqArray,out(:,2)];
  
endfunction

##function [bMA,bMB] = dailyModFit(Y,reZX,imZX,numDesignCol,dataLength) %UPDATE%
##	if (nargin != 5)
##		usage('[bMA,bMB] = dailyModFit(Y,reZX,imZX,numDesignCol,dataLength);');
##	endif
##	
##	freqArray = (0:(dataLength/2))' ./ (dataLength);
##	bMA = ones(rows(freqArray),numDesignCol + 1);
##	bMB = ones(size(bMA));
##	bMA(:,1) = freqArray;
##	bMB(:,1) = freqArray;
##
##	%Fits for component amplitudes at all frequencies for the real and imaginary components
##	bMA(:,2:end) = [reZX(:,:,1)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,2)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,3)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,4)*reshape(Y,rows(Y)*columns(Y),1)];
##	bMB(:,2:end) = [imZX(:,:,1)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,2)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,3)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,4)*reshape(Y,rows(Y)*columns(Y),1)];
##endfunction
      
  
