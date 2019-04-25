function [allA,allB,freqArray] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength,freqInterval) %UPDATE%
	if (nargin != 7)
		usage('[bMA,bMB] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength,freqInterval);');
	endif
	
	freqArray = (0:(dataLength/2))' ./ (dataLength);
	out = ones(rows(freqArray),numDesignCol + 1,2);
	columns(Y)/2
	for freqCount = 1:columns(Y)/2
		freqCount
		fflush(stdout);
		BETA = (ZX*Y(:,2*(freqCount-1) + 1:2*freqCount));
		BETA = [BETA(1,:);zeros(1,2);BETA(2,:);zeros(1,2);BETA(3,:);zeros(1,2);BETA(4:end,:)]; %The first block is only 3 x numHours for original freq
		newBETA = ones(n,numDesignCol + 1,2);
		for count = 1:n
			newBETA(count,:,1) = [(freqCount-1)*(freqInterval)+(count-1)/dataLength,BETA(((count-1)*numDesignCol)+1:count*numDesignCol,1)'];
			newBETA(count,:,2) = [(freqCount-1)*(freqInterval)+(count-1)/dataLength,BETA(((count-1)*numDesignCol)+1:count*numDesignCol,2)'];
		endfor
		out(((freqCount-1)*n)+1:freqCount*n,:,1) = newBETA(:,:,1);
		out(((freqCount-1)*n)+1:freqCount*n,:,2) = newBETA(:,:,2);
	endfor
	%assert(freqArray,out(:,1,1));
	%Sets up return arrays
	allA = [out(:,:,1)];
	allB = [out(:,:,2)];
  
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
      
  
