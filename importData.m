clear O;

O = load('fakeDarkEPAugust92017.dat');

fullHour = 4096;
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

%Makes sure that the division worked correctly 
fullTimeSeries = [];
for count = 1:rows(divHours)
	fullTimeSeries = [fullTimeSeries;divHours{count,1}];
endfor
assert(O,fullTimeSeries);

for count = 1:rows(divHours)
	if (rows(divHours{count,1}) != fullHour)
		divHours(count,:) = [];
	endif
endfor
fullLength = rows(divHours)*fullHour;

