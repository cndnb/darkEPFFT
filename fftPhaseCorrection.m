function rtn = fftPhaseCorrection(compOut,freqArray,hourLength)
	if(nargin != 3)
		error("fftPhaseCorrection - rtn = fftPhaseCorrection(compOut,freqArray,hourLength)");
	endif

	%Corrects phase for fft starting at different times
	colCorrect = exp((2*pi*i*(hourLength)).*fSeries);
	corArray = zeros(rows(fSeries),columns(compOut));
	for count = 1:columns(compOut)
		corArray(:,count) = colCorrect.^(count-1);
	endfor
	compOut = compOut.*corArray;	

	%Returns modified compOut corrected for phase
	rtn = compOut;
endfunction

%!test
%! hourLength = 4096;
%! freqArray = (0:hourLength/2)'./hourLength;
%! cosineCheck = ones(hourLength*numHours,1);
%! sineCheck = i.*cosineCheck;
%! 
