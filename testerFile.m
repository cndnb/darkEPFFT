%Importing data
if (!exist('divHours'))
	error('need data');
endif
[A,B,t] = darkEPFFT(divHours);

figure(1);
waterfall(t,A(:,1),A(:,2:end));
title('Cosine amplitude')
xlabel('hours');
ylabel('Frequency (Hz)');
zlabel('FFT Amplitude');

figure(2);
waterfall(t,B(:,1),B(:,2:end));
title('Sine amplitude');
xlabel('hours');
ylabel('Frequency (Hz)');
zlabel('FFT Amplitude');

%Initializing design matrix (very large)
omegaEarth = 2*pi*(1/86164.0916);
omegaEarthHr = omegaEarth*3600; %(3600s / 1 hr)
hourLength = 4096;
fullLength = rows(divHours)*hourLength;
designColumns = 5;
numHours = rows(divHours);
numBlocks = floor(fullLength/hourLength); 
if ((!exist('Z'))||(!exist('X')))
	disp('Calculating Z and X');
	fflush(stdout);
	importXCov;
	disp('done');
	fflush(stdout);
endif 

tA = A(:,2:end)';
tB = B(:,2:end)';
Y = zeros(rows(tA),2*columns(tA));
for count = 1:columns(tA)
	Y(:,2*(count-1)+1:2*count) = [tA(:,count),tB(:,count)];
endfor
Y = repmat(Y,numBlocks,1);

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
[bMA,bMB] = dailyModFit(Y,ZX,numBlocks,designColumns,numHours,fullLength);
disp('done');
disp('Converting time amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q);
disp('done');
fflush(stdout);

figure(3);
loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4),pwr(:,1),pwr(:,5));
title('Torque Power vs. Frequency');
legend('Z','perpX','paraX','sum');
xlabel('Frequency (Hz)');
ylabel('Torque Power');
