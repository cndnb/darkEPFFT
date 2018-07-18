%for count = 1:rows(bMA)
%	count
%	fflush(stdout);
%	assert(abs(bMA(count,1)-freqArray(count,1))<2*eps);
%endfor

t = (1:4096)';
A = 1; omega = 2*pi*(1/4096);
data = [t,A.*sin(omega.*t)];
divHours = cell(1,2);
divHours{1,1} = data; divHours{1,2} = 1;
[A,B,t] = darkEPFFT(divHours);
compOut = A(:,2)+i*B(:,2);
compOut = [compOut;conj(flip(compOut(2:end-1,:)))];
recoveredTime = ifft(compOut);
assert(abs(real(recoveredTime).-data(:,2)) < 2*eps);		

