function [rtn,corArray] = fftPhaseCorrection(compOut,freqArray,hourLength,timeHours)
	if(nargin != 4)
		error("fftPhaseCorrection - rtn = fftPhaseCorrection(compOut,freqArray,hourLength,tH)");
	endif

	%Corrects phase for fft starting at different times
	corArray = exp((2*pi*i*(hourLength)).*(freqArray*(timeHours.-1)'));

	%Returns modified compOut corrected for phase
	rtn = compOut.*corArray;
endfunction

%FUNCTION ROTATES BY MULTIPLES OF 2pi!

%!test
%! numHours = 10;
%! timeHours = (1:10)';
%! hourLength = 4096;
%! freqArray = (0:hourLength/2)'./hourLength;
%! cosineCheck = ones(hourLength/2+1,numHours);
%! sineCheck = i.*cosineCheck;
%! correctedSine=fftPhaseCorrection(sineCheck,freqArray,hourLength,timeHours);
%! correctedCosine=fftPhaseCorrection(cosineCheck,freqArray,hourLength,timeHours);
%! for count = 1:columns(correctedSine)
%! 	assert(real(correctedSine(:,count)),sin(2*pi*hourLength.*freqArray*count-1));
%! 	assert(real(correctedCosine(:,count)),cos(2*pi*hourLength.*freqArray*count-1));
%! endfor
