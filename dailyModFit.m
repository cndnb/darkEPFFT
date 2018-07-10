function [bMA,bMB] = dailyModFit(Y,reZX,imZX,numDesignCol,dataLength) %UPDATE%
	if (nargin != 5)
		usage('[bMA,bMB] = dailyModFit(Y,reZX,imZX,numDesignCol,dataLength);');
	endif
	
	freqArray = (0:(dataLength/2))' ./ (dataLength);
	bMA = ones(rows(freqArray),numDesignCol + 1);
	bMB = ones(size(bMA));
	bMA(:,1) = freqArray;
	bMB(:,1) = freqArray;

	%Fits for component amplitudes at all frequencies for the real and imaginary components
	bMA(:,2:end) = [reZX(:,:,1)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,2)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,3)*reshape(Y,rows(Y)*columns(Y),1),reZX(:,:,4)*reshape(Y,rows(Y)*columns(Y),1)];
	bMB(:,2:end) = [imZX(:,:,1)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,2)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,3)*reshape(Y,rows(Y)*columns(Y),1),imZX(:,:,4)*reshape(Y,rows(Y)*columns(Y),1)];
endfunction
      
  
