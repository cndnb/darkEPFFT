function [rtn,fullLength,indArray] = importData(dMatrix,hourLength); %FIX
	if(nargin != 2)
		error('importData - [divHours,fullLength] = importData(dMatrix,hourLength)');
	endif

  %Initializes index finding array, subtracts beginning value so modulus works
	tempO = dMatrix(:,1).-dMatrix(1,1);
  %Every hour starts with zero after modulus
  tempO = mod(tempO,hourLength);
  %Will catch negative values
	tempO(2:end) = tempO(2:end) - tempO(1:end-1);
  %divTemp avoids dividing by zero
  divTemp = tempO;
  nonZeroInd = find(divTemp);
	divTemp(nonZeroInd,1) = abs(1./tempO(nonZeroInd));
  %By dividing by abs value and subtracting one, negatives stay negative 
  %positive usual counting values go to zero, 
  %find can pick of hour starting indices
	tempO = tempO.*divTemp .- 1;
	indArray = find(tempO);
  %If the beginning isn't included, include it
  if(indArray(1,1)!= 1)
    indArray = [1;indArray];
  endif
  %If the end isn't included, include it
  if(indArray(end,1)!= rows(dMatrix))
    indArray = [indArray;rows(dMatrix)+1];
  endif
  
  %Initializes accumulation array
	divHours = cell(rows(indArray) - 1,2);
	for count = 1:rows(indArray)-1
		divHours{count,1} = dMatrix(indArray(count):indArray(count+1)-1,:);
		divHours{count,2} = floor(dMatrix(indArray(count),1)/hourLength)+1;
	endfor
	

	%Removes cells that have less than hourLength datapoints
  divRemoved = 0;
  for count = 1:rows(divHours)
		if (rows(divHours{count - divRemoved,1}) != hourLength)
			divHours(count - divRemoved,:) = [];
			divRemoved = divRemoved + 1;
		endif
	endfor

	%Returns values
	fullLength = rows(divHours)*hourLength;
	rtn = divHours;
endfunction
	
%!test
%! t=1:1e3; t=t';
%! fData = [t,randn(rows(t),1)];
%! [divHours,fullLength] = importData(fData,100);
%! fullTimeSeries = [];
%! for count = 1:rows(divHours)
%!	fullTimeSeries = [fullTimeSeries;divHours{count,1}];
%! endfor
%! assert(fData(1:rows(fullTimeSeries),:),fullTimeSeries);
%! assert(cell2mat(divHours(:,2)),(1:10)');

