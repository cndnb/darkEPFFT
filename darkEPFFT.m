function [ampFreq,ampError] = darkEPFFT(data)
	A = ones(rows(data),1); %Initializes collection array for cosine component
	B = ones(rows(data),1); %Initializes collection array for sine component
	for count = 1:rows(data)
		A(count,1) = fft(data{count,1});
		B(count,1) = fft(data{count,1});
	endfor
endfunction
		
