function [bMA,bMB] = dailyModFit(Y,ZX,numDesignCol,dataLength) %UPDATE%
	if (nargin != 4)
		usage('out = dailyModFit(Y,ZX,numDesignCol,dataLength);');
	endif
	
	freqArray = (0:(dataLength/2))' ./ (dataLength);
	bMA = ones(rows(freqArray),numDesignCol + 1);
  bMB = ones(size(bMA));
  bMA(:,1) = freqArray;
  bMB(:,1) = freqArray;
  rows(out)
  for freq = 1:rows(out)
    freq
    fflush(stdout);
    for count = 2:numDesignCol + 1
      bMA(:,count) = reshape(ZX{count,freq,1},rows(ZX)*columns(ZX),1)*reshape(Y,rows(Y)*columns(Y),1);
      bMB(:,count) = reshape(ZX{count,freq,2},rows(ZX)*columns(ZX),1)*reshape(Y,rows(Y)*columns(Y),1);
    endfor
  endfor
endfunction
      
  
