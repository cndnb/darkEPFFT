function [A,B] = darkEPFFT(data)
	%Checks that the input matrix has the correct size and is not complex
	for count = 1:rows(data)
		assert(rows(data{count,1}) == 4096, 'data must be 2^N (4096) length');
		assert(imag(data{count,1}) == 0,'data must be real')
	endfor
	
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
	%Checks that array is symmetric about the nyquist frequency
	assert(compOut(2:rows(compOut)/2,:),conj(flip(compOut((rows(compOut)/2)+2:end,:))));
	%Since array is symmetric about the nyquist frequency, half the matrix can be removed
	compOut = compOut(1:((rows(compOut)/2) + 1),:);
	%Checks that the number of frequencies lines up with the number of values.
	assert(rows(fSeries), rows(compOut));
	
	%Prepares output arrays
	A = [fSeries,real(compOut)]; %Cosine components of FFT (columns correspond to hours)
	B = [fSeries,imag(compOut)]; %Sine components of FFT (columns correspond to hours)
endfunction
		
