function [betaModA,betaModB] = dailyModFit(A,B,t) %NEEDS TO BE UPDATED%
	omegaEarth = 2*pi*(1/86164.0916);
	omegaEarthHr = omegaEarth*3600; %(3600 s / 1 hr)
	designMatrix = [ones(rows(t),1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];

	%Fits time varying amplitude values for earth freq modulation
	[bA,sA,rA,errA,covA] = ols2(A(:,2:end)',designMatrix);
	[bB,sB,rB,errB,covB] = ols2(B(:,2:end)',designMatrix);

	%Sets up return arrays
	betaModA = [A(:,1), bA'];
	betaModB = [B(:,1), bB'];
  
endfunction
