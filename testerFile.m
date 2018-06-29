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
numBlocks = floor(runLength/hourLength) + 1; %Plus one for original frequency to be included
if ((!exist('Z'))||(!exist('X')))
	disp('Calculating Z and X');
	fflush(stdout);
	X = zeros(numHours*(numBlocks),designColumns*(numBlocks) - 2);
	X(1:numHours,1:3) = [ones(numHours,1),sin(omegaEarthHr.*t),cos(omegaEarthHr.*t)];
	for count = 2:numBlocks
		X(((count-1)*numHours+1):(count*numHours),((count-1)*designColumns+1) - 2:(count*designColumns) - 2) = ...
			[ones(numHours,1),...
			 sin(omegaEarthHr.*t),...
			 cos(omegaEarthHr.*t),...
			 sin(((count*3600)/(2*runLength)).*t),... %Needs to be correct freq units
			 cos(((count*3600)/(2*runLength)).*t)];   %Needs to be correct freq units
	endfor

	Z = inv(X' * X);
	ZX = Z * X';
endif 

tA = A(:,2:end)';
tB = B(:,2:end)';
Y = zeros(rows(tA),2*columns(tA));
for count = 1:columns(tA)
	Y(:,2*(count-1)+1:2*count) = [tA(:,count),tB(:,count)];
endfor
Y = repmat(Y,numBlocks,1);
disp('done');
fflush(stdout);

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
[bMA,bMB] = dailyModFit(Y,ZX,numBlocks,designColumns,numHours,runLength);
disp('done');
disp('Converting time amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q);
disp('done');
fflush(stdout);

figure(1);
loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4),pwr(:,1),pwr(:,5));
title('Torque Power vs. Frequency');
legend('Z','perpX','paraX','sum');
xlabel('Frequency (Hz)');
ylabel('Torque Power');
