function [A,B,t] = darkEPFFT(data)
	%Finds the collection inteval for the discrete fourier transform
	interval = data{1,1}(2,1) - data{1,1}(1,1);
	hourLength = rows(data{1,1});
	tH = cell2mat(data(:,2)); %Gets hour count for each column from data output

	%Collects the array into a form that fft can operate on
	preCollectArray = cell2mat(data(:,1));
	collectArray = reshape(preCollectArray(:,2),hourLength,rows(data));

	%Calculates fft for each chunk simultaneously multiplied by 2 for one sided power spectrum
	compOut = (2/rows(collectArray)).*fft(collectArray);
	%Creates frequency array for only 0 to 1/(2*interval) frequencies
	fSeries = ((0:rows(compOut)/2)')./(rows(compOut)*interval);
	%Since array is symmetric about the nyquist frequency, half the matrix can be removed
	compOut = compOut(1:((rows(compOut)/2) + 1),:);

	%1 and end values should not be multiplied by 2
	compOut(1,:) = compOut(1,:)./2;
	compOut(end,:) = compOut(end,:)./2;

	%Corrects phase values to reflect hours they started at
	%phaseCorrected = fftPhaseCorrection(compOut,fSeries,hourLength,tH);
	phaseCorrected = compOut;
	
	%Prepares output arrays
	A = [fSeries,real(phaseCorrected)]; %Cosine components of FFT (columns correspond to hours)
	B = [fSeries,imag(phaseCorrected)]; %Sine components of FFT (columns correspond to hours)
	t = tH;
endfunction

%!test
%! t = (1:4096)';
%! data = [t,randn(rows(t),1)];
%! divHours = cell(1,2);
%! for count = 1:10
%! 	divHours{count,1} = data; divHours{count,2} = count;
%! endfor
%! [cosTerms,sinTerms,t] = darkEPFFT(divHours);
%! compOut = (cosTerms(:,2:end) + i*sinTerms(:,2:end));
%! compOut(1,:) = 2.*compOut(1,:);
%! compOut(end,:) = 2.*compOut(end,:);
%! fullCompOut = [compOut;conj(flip(compOut(2:end-1,:)))];
%! fullCompOut = (4096/2).*fullCompOut;
%! recoveredTime = ifft(fullCompOut);
%! for count = 1:10 %Checks that having multiple rows doesn't mess up analysis
%! 	%assert(real(recoveredTime(:,count)),data(:,2),4*eps);%Checks that recreated time series is the same
%! 	assert(fullCompOut(:,count)'*fullCompOut(:,count)/4096,data(:,2)'*data(:,2));%Tests parseval's theorem
%! endfor
