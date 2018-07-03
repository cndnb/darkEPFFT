for count = 1:rows(bMA)
	count
	fflush(stdout);
	assert(abs(bMA(count,1)-freqArray(count,1))<2*eps);
endfor
