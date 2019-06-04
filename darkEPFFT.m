function [A,B,t] = darkEPFFT(data)
	%Finds the collection inteval for the discrete fourier transform
	interval = data{1,1}(2,1) - data{1,1}(1,1);
	hourLength = rows(data{1,1});

	%Collects the array into a form that fft can operate on
	preCollectArray = cell2mat(divHours(:,1));
	collectArray = reshape(preCollectArray,hourLength,rows(divHours));

	%Calculates fft for each chunk simultaneously multiplied by 2 for one sided power spectrum
	compOut = (2/rows(collectArray)).*fft(collectArray);
	%Creates frequency array for only 0 to 1/(2*interval) frequencies
	fSeries = ((0:rows(compOut)/2)')./(rows(compOut)*interval);
	%Since array is symmetric about the nyquist frequency, half the matrix can be removed
	compOut = compOut(1:((rows(compOut)/2) + 1),:);

	%Corrects phase for fft starting at different times
	colCorrect = exp((2*pi*i*(hourLength)).*fSeries);
	corArray = zeros(rows(fSeries),columns(compOut));
	for count = 1:columns(compOut)
		corArray(:,count) = colCorrect.^(count-1);
	endfor
	compOut = compOut.*corArray;	

	%1 and end values should not be multiplied by 2
	compOut(1,:) = compOut(1,:)./2;
	compOut(end,:) = compOut(end,:)./2;
	
	%Prepares output arrays
	A = [fSeries,real(compOut)]; %Cosine components of FFT (columns correspond to hours)
	B = [fSeries,imag(compOut)]; %Sine components of FFT (columns correspond to hours)
	t = cell2mat(data(:,2)); %Labels hour counter for each row
endfunction

##%!test
##%! t = (1:4096)';
##%! A = 1; omega = 2*pi*(1/100);
##%! data = [t,A.*sin(omega.*t)];
##%! divHours = cell(1,2);
##%! for count = 1:10
##%! 	divHours{count,1} = data; divHours{count,2} = count;
##%! endfor
##%! [cosTerms,sinTerms,t] = darkEPFFT(divHours);
##%! compOut = (cosTerms(:,2:end) + i*sinTerms(:,2:end));
##%! compOut(1,:) = 2.*compOut(1,:);
##%! compOut(end,:) = 2.*compOut(end,:);
##%! fullCompOut = [compOut;conj(flip(compOut(2:end-1,:)))];
##%! fullCompOut = (4096/2).*fullCompOut;
##%! recoveredTime = ifft(fullCompOut);
##%! for count = 1:10 %Checks that having multiple rows doesn't mess up analysis
##%! 	assert(real(recoveredTime(:,count)),data(:,2),4*eps);%Checks that recreated time series is the same
##%! 	assert(fullCompOut(:,count)'*fullCompOut(:,count)/4096,data(:,2)'*data(:,2));%Tests parseval's theorem
##%! endfor
