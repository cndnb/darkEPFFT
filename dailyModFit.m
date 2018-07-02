function [allA,allB] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength) %NEEDS TO BE UPDATED%
	if (nargin != 6)
		usage('[bMA,bMB] = dailyModFit(Y,ZX,n,numDesignCol,numHours,dataLength);');
	endif
	
	freqArray = (0:dataLength)' ./ (dataLength);
	out = ones(rows(freqArray),numDesignCol + 1,2);
	columns(Y)/2
	for freqCount = 1:columns(Y)/2
		freqCount
		fflush(stdout);
		BETA = (ZX*Y(:,2*(freqCount-1) + 1:2*freqCount));
		BETA = [BETA(1,:);zeros(1,2);BETA(2,:);zeros(1,2);BETA(3,:);zeros(1,2);BETA(4:end,:)]; %The first block is only 3 x numHours for original freq
		newBETA = ones(n,numDesignCol + 1,2);
		for count = 1:n
			newBETA(count,:,1) = [(freqCount-1)*(2.4414e-4)+(count-1)/dataLength,BETA(((count-1)*numDesignCol)+1:count*numDesignCol,1)'];
			newBETA(count,:,2) = [(freqCount-1)*(2.4414e-4)+(count-1)/dataLength,BETA(((count-1)*numDesignCol)+1:count*numDesignCol,2)'];
		endfor
		out(((freqCount-1)*n)+1:freqCount*n,:,1) = newBETA(:,:,1);
		out(((freqCount-1)*n)+1:freqCount*n,:,2) = newBETA(:,:,2);
	endfor
	
	%Sets up return arrays
	allA = [freqArray,out(:,:,1)];
	allB = [freqArray,out(:,:,2)];
  
endfunction
