function [rtn,fullLength] = importData(dMatrix,hourLength); %FIX
	if(nargin != 2)
		error('importData - [divHours,fullLength] = importData(dMatrix,hourLength)');
	endif

	%Choosing data
	O = dMatrix;

	%Subtracts one so that first time point is zero
	tempO = O(:,1).-1;
	%Makes it so that every hour starts with a zero in tempO
	tempO = mod(tempO,hourLength-1);
	%Switches to looking at difference between n and n+1 times, so if a day passes but there
	%is no zero the difference will be negative
	tempO(2:end) = tempO(2:end) - tempO(1:end-1);
	%this makes it so that there are no infinities in the array
	divTemp = 1./tempO; infInd = isinf(divTemp);
	divTemp(find(infInd)) = -1.*ones(rows(find(infInd)),1); 
	%This separates each cell array by finding zeros
	tempO = tempO.*abs(1./tempO) .- 1;
	%Indexing array that separates the intended days
	indArray = find(tempO);
	%Initializes accumulation array
	divHours = cell(rows(indArray) - 1,2);
	%Runs through index array values
	for count = 1:rows(indArray)-1
		%Assigns first column to be the hourLength matrix of data size = (<=hourLength,2)
		divHours{count,1} = O(indArray(count):indArray(count+1),:);
		%Assigns time in hours from the first cut to the second column of the cell
		divHours{count,2} = floor(O(indArray(count),1)/hourLength);
	endfor
	

	%Removes cells that have less than hourLength datapoints--less noise in FFT data
	divRemoved = 0;
	for count = 1:rows(divHours)
		if(rows(divHours{count-divRemoved,1}(:,1)) != hourLength)
			divHours(count-divRemoved,:) = [];
			divRemoved = divRemoved + 1;
		endif
	endfor

	%Returns values
	fullLength = rows(divHours)*hourLength;
	rtn = divHours;
endfunction
	
%!test
%! t=1:1e5; t=t';
%! fData = [t,randn(rows(t),1)];
%! [divHours,fullLength] = importData(fData,4096);
%! fullTimeSeries = [];
%! for count = 1:rows(divHours)
%!	fullTimeSeries = [fullTimeSeries;divHours{count,1}];
%! endfor
%! assert(fData(1:rows(fullTimeSeries),:),fullTimeSeries);

