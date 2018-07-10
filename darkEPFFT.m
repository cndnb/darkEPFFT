function [rtn,t] = darkEPFFT(data)
	%Checks that the input matrix has the correct size and is not complex
	divLength = 4096; %Optimized for FFT computation
	for count = 1:rows(data)
		assert(rows(data{count,1}) == divLength,char('Data must have length',num2str(divLength)));
		assert(imag(data{count,1}) == zeros(rows(data{count,1}),1),'data must be real')
	endfor
	
	%Finds the collection inteval for the discrete fourier transform
	interval = data{1,1}(2,1) - data{1,1}(1,1);

	%Collects the array into a form that fft can operate on
	collectArray = ones(rows(data{1,1}),rows(data));
	for count = 1:rows(data)
		collectArray(:,count) = data{count,1}(:,2);
	endfor

	%constLinearRmX = [ones(divLength,1),(1:divLength)'];
	%[cLRB,clRS,clRR,clRErr,clRCov] = ols2(collectArray,constLinearRmX);
	%driftFix = collectArray .- constLinearRmX*cLRB;

	%Calculates fft for each chunk simultaneously
	%compOut = fft(driftFix); %(Removed drift)
	compOut = fft(collectArray); %(No drift fix)
	%Creates frequency array for only 0 to 1/(2*interval) frequencies
	fSeries = ((0:rows(compOut)/2)')./(rows(compOut)*interval);
	%Checks that array is symmetric about the nyquist frequency
	assert(compOut(2:rows(compOut)/2,:),conj(flip(compOut((rows(compOut)/2)+2:end,:))));
	%Since array is symmetric about the nyquist frequency, half the matrix can be removed
	compOut = compOut(1:((rows(compOut)/2) + 1),:);
	%Checks that the number of frequencies lines up with the number of values.
	assert(rows(fSeries), rows(compOut));
	
	%Prepares output arrays
	%A = [fSeries,real(compOut)]; %Cosine components of FFT (columns correspond to hours)
	%B = [fSeries,imag(compOut)]; %Sine components of FFT (columns correspond to hours)
  rtn = compOut'; %Returns columns as frequencies and rows as hours
	t = cell2mat(data(:,2)); %Labels hour counter for each row
endfunction

%!test
%! t = (1:4096)';
%! A = 1; omega = 2*pi*(1/4096);
%! data = [t,A.*sin(omega.*t)];
%! divHours = cell(1,2);
%! divHours{1,1} = data; divHours{1,2} = 1;
%! [out,t] = darkEPFFT(divHours);
%! compOut = out';
%! compOut = [compOut;conj(flip(compOut(2:end-1,:)))];
%! recoveredTime = ifft(compOut);
%! assert(abs(real(recoveredTime).-data(:,2)) < 4*eps);		
