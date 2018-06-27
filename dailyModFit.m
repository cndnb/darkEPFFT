function dailyModFit(A,B)
	omegaEarthHr = 2*pi*
	designMatrix = [ones(columns(A)),sin(omegaEarthHr.*((1:columns(A))')),cos(omegaEarthHr.*((1:columns(A))'))];
endfunction
