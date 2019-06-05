function rtn = fftPhaseCorrection(compOut,freqArray,hourLength)
	if(nargin != 3)
		error("fftPhaseCorrection - rtn = fftPhaseCorrection(compOut,freqArray,hourLength)");
	endif

	%Corrects phase for fft starting at different times
	colCorrect = exp((2*pi*i*(hourLength)).*freqArray);
	corArray = zeros(rows(freqArray),columns(compOut));
	for count = 1:columns(compOut)
		corArray(:,count) = colCorrect.^(count-1);
	endfor	

	%Returns modified compOut corrected for phase
	rtn = compOut.*corArray;
endfunction

%!test
%! numHours = 10;
%! hourLength = 4096;
%! freqArray = (0:hourLength/2)'./hourLength;
%! cosineCheck = ones(hourLength/2+1,numHours);
%! sineCheck = i.*cosineCheck;
%! correctedSine=fftPhaseCorrection(sineCheck,freqArray,hourLength);
%! correctedCosine=fftPhaseCorrection(cosineCheck,freqArray,hourLength);
%! for count = 1:columns(correctedSine)
%! 	assert(real(correctedSine)(:,count),sin(2*pi*hourLength.*freqArray*count));
%! 	assert(real(correctedCosine)(:,count),cos(2*pi*hourLength.*freqArray*count));
%! endfor
