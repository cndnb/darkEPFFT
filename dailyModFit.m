function [betaModA,betaModB] = dailyModFit(A,B)
	
  omegaEarth = 2*pi*(1/86164.0916);
  omegaEarthHr = omegaEarth*3600; %(3600 s / 1 hr)
	designMatrix = [ones(columns(A)),sin(omegaEarthHr.*((1:columns(A))')),cos(omegaEarthHr.*((1:columns(A))'))];
  [bA,sA,rA,errA,covA] = ols2(A(2:end,:)',designMatrix);
  [bB,sB,rB,errB,covB] = ols2(B(2:end,:)',designMatrix);
  betaModA = [A(:,1), bA'];
  betaModB = [B(:,1), bB'];
  
endfunction
