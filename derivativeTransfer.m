function rtn = derivativeTransfer(freqArray,I,kappa,Q)
	if(nargin != 4)
		error('rtn = derivativeTransfer(freqArray,I,kappa,Q)');
	endif
	
	omegaFreq = (2*pi).*freqArray;
	denom = I*((-1/6).*cos(2.*omegaFreq)+(4/3)*cos(omegaFreq) - (5/2)) + kappa*(1+(i/Q)).*ones(rows(omegaFreq),1);
	rtn = 1./denom
endfunction
