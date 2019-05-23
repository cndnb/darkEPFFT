function [rtn,fullLength] = importData(dMatrix,hourLength);
	if(nargin != 2)
		error('importData - [divHours,fullLength] = importData(dMatrix,hourLength)');
	endif

	%Choosing data
	O = dMatrix;

%	bigArray = zeros(ceil(rows(O)/hourLength)*hourLength,columns(O));
%	bigArray(1:rows(O),:) = O;
%	divHours = mat2cell(bigArray,hourLength.*ones(1,ceil(rows(O)/hourLength)),2);
%
%	divRemoved = 0;
%	for count = 1:rows(divHours)
%		if(isnan(divHours{count-divRemoved,1}(:,1)./0) != false(hourLength,1))
%			divHours(count-divRemoved,:) = [];
%			divRemoved = divRemoved + 1;
%		else
%			divHours(count-divRemoved,2) = count;
%		endif
%	endfor


	%Sorting into hour length chunks
	fullHour = hourLength;
	tempO = [O(:,1),O];
	tempO(:,1) = tempO(:,1).-1;
	tempO(:,1) = mod(tempO(:,1),fullHour);
	divHours = cell(0,2);
	lastTime = fullHour;
	hourCount = 0;
	for count = 1:rows(tempO)
		if (lastTime > tempO(count,1))
			hourCount = hourCount + 1;
			divHours{hourCount,2} = hourCount; %Allows recovery of specific time later
			divHours{hourCount,1} = O(count,:);
		else
			divHours{hourCount,1} = [divHours{hourCount,1};O(count,:)];
		endif	
		lastTime = tempO(count,1);
	endfor

	divRemoved = 0;
	for count = 1:rows(divHours)
		if (rows(divHours{count - divRemoved,1}) != fullHour)
			divHours(count - divRemoved,:) = [];
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

