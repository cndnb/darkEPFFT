function [rtn,fullLength] = importData(dMatrix,hourLength); %FIX
	if(nargin != 2)
		error('importData - [divHours,fullLength] = importData(dMatrix,hourLength)');
	endif

	%Choosing data
	O = dMatrix;

	tempO = O(:,1).-1;
	tempO = mod(tempO,hourLength);
	tempO(2:end) = tempO(2:end) - tempO(1:end-1);
	divTemp = 1./tempO; infInd = isinf(divTemp);
	divTemp(infInd) = zeros(rows(infInd),1); 
	tempO = tempO.*abs(1./tempO) .- 1;
	indArray = find(tempO);
	divHours = cell(rows(indArray) - 1,2);
	for count = 1:rows(indArray)-1
		try
		divHours{count,1} = O(indArray(count):indArray(count+1),:);
		divHours{count,2} = floor(O(indArray(count),1)/hourLength);
		catch
			indArray(count)
			fflush(stdout);
			error('this sucks');
		end_try_catch
	endfor
	

	%Removes cells that have less than hourLength datapoints
	divRemoved = 0;
	for count = 1:rows(divHours)
		if(isnan(divHours{count-divRemoved,1}(:,1)./0) != false(hourLength,1))
			divHours(count-divRemoved,:) = [];
			divRemoved = divRemoved + 1;
		else
			divHours(count-divRemoved,2) = count;
		endif
	endfor


%	%Sorting into hour length chunks
%	fullHour = hourLength;
%	tempO = [O(:,1),O];
%	tempO(:,1) = tempO(:,1).-1;
%	tempO(:,1) = mod(tempO(:,1),fullHour);
%	divHours = cell(0,2);
%	lastTime = fullHour;
%	hourCount = 0;
%	for count = 1:rows(tempO)
%		if (lastTime > tempO(count,1))
%			hourCount = hourCount + 1;
%			divHours{hourCount,2} = hourCount; %Allows recovery of specific time later
%			divHours{hourCount,1} = O(count,:);
%		else
%			divHours{hourCount,1} = [divHours{hourCount,1};O(count,:)];
%		endif	
%		lastTime = tempO(count,1);
%	endfor
%
%	divRemoved = 0;
%	for count = 1:rows(divHours)
%		if (rows(divHours{count - divRemoved,1}) != fullHour)
%			divHours(count - divRemoved,:) = [];
%			divRemoved = divRemoved + 1;
%		endif
%	endfor

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

