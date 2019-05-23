function [allA,allB] = dailyModFit(Y,ZX,n) %UPDATE%
	if (nargin != 3)
		error('[bMA,bMB] = dailyModFit(Y,ZX,n);');
	endif
	
	%Sets up accumulation array
	out = zeros(columns(ZX)/2,2);
	%Creates BETA array of amplitudes
	matBeta = ZX*Y;
	%Stacks columns into single column vector
	BETA = reshape(matBeta,[],1);
	%BETA goes [sin;cos;sin ...] terms, this sorts it into [sin,cos;sin,cos;...]
	preOut = reshape(BETA',2,[])';
	
	%Gets rid of extra wings on symmetric fit
	out = preOut(-floor(-n/2)+1:end+floor(-n/2)+1,:);

	%Sets up return arrays
	allA = out(:,1);
	allB = out(:,2);
endfunction

%!test
%! t = (1:4096)';
%! X = [ones(4096,1),cos((2*pi*(1/4096)).*t)];
%! ZX = inv(X'*X)*X';
%! Y = ones(4096,1);
%! [A,B] = dailyModFit(Y,ZX,2);
%! assert(A,1);
%! assert(B,0,eps);
