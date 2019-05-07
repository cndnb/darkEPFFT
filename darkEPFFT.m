function [A,B,t] = darkEPFFT(data)
	%Finds the collection inteval for the discrete fourier transform
	interval = data{1,1}(2,1) - data{1,1}(1,1);

	%Collects the array into a form that fft can operate on
	collectArray = ones(rows(data{1,1}),rows(data));
	for count = 1:rows(data)
		collectArray(:,count) = data{count,1}(:,2);
	endfor

	%Calculates fft for each chunk simultaneously
	compOut = fft(collectArray);
	%Creates frequency array for only 0 to 1/(2*interval) frequencies
	fSeries = ((0:rows(compOut)/2)')./(rows(compOut)*interval);
	%Since array is symmetric about the nyquist frequency, half the matrix can be removed
	compOut = compOut(1:((rows(compOut)/2) + 1),:);
	
	%Prepares output arrays
	A = [fSeries,real(compOut)]; %Cosine components of FFT (columns correspond to hours)
	B = [fSeries,imag(compOut)]; %Sine components of FFT (columns correspond to hours)
	t = cell2mat(data(:,2)); %Labels hour counter for each row
endfunction

%!test
%! t = (1:4096)';
%! A = 1; omega = 2*pi*(1/100);
%! data = [t,A.*sin(omega.*t)];
%! divHours = cell(1,2);
%! divHours{1,1} = data; divHours{1,2} = 1;
%! [out,t] = darkEPFFT(divHours);
%! compOut = out';
%! compOut = [compOut;conj(flip(compOut(2:end-1,:)))];
%! recoveredTime = ifft(compOut);
%! assert(abs(real(recoveredTime).-data(:,2)) < 4*eps);	

%!test
%! t = (1:4096)';
%! A = 1; omega = 2*pi*(1/100);
%! data = [t,A.*sin(omega.*t)];
%! divHours = cell(1,2);
%! divHours{1,1} = data; divHours{1,2} = 1;
%! [A,B,t] = darkEPFFT(divHours);
%! compOut = A(:,2)+i*B(:,2);
%! compOut = [compOut;conj(flip(compOut(2:end-1,:)))];
%! Y = divHours{1,1}(:,2);
%! assert(abs(sum(Y.*Y)-(compOut' * compOut)/rows(data)) < (4096 + 1)*eps);
