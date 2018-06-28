%Importing data
if (!exist('divHours'))
	error('need data');
endif
[A,B,t] = darkEPFFT(divHours);

%Initializing design matrix (very large)
omegaEarth = 2*pi*(1/86164.0916);
omegaEarthHr = omegaEarth*3600; %(3600s / 1 hr)
hourLength = 4096;
runLength = 1e6;
designColumns = 5;
numHours = rows(divHours);
numBlocks = runLength/hourLength;
X = zeros(numHours*numBlocks,designColumns*numBlocks);
for count = 1:numBlocks
	X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1):(count*designColumns)) = ...
		[ones(numHours,1),...
		 sin(omegaEarthHr.*t),...
		 cos(omegaEarthHr.*t),...
		 sin((count/runLength).*t),... %Needs to be correct freq units
		 cos((count/runLength).*t)];   %Needs to be correct freq units
endfor

%Fitting using precomputed design matrix to find variations in A,B over time
[bMA,bMB] = dailyModFit(A,B,X);
pwr = convertToPower(bMA,bMB,kappa,f0,Q);
figure(1);
loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4),pwr(:,1),pwr(:,5));
title('Torque Power vs. Frequency');
legend('Z','perpX','paraX','sum');
xlabel('Frequency (Hz)');
ylabel('Torque Power');
