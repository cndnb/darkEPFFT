%Importing data
if (!exist('divHours'))
	error('need data');
endif
[compOut,t] = darkEPFFT(divHours);

%figure(1);
%waterfall(t,A(:,1),A(:,2:end));
%title('Cosine amplitude')
%xlabel('hours');
%ylabel('Frequency (Hz)');
%zlabel('FFT Amplitude');
%
%figure(2);
%waterfall(t,B(:,1),B(:,2:end));
%title('Sine amplitude');
%xlabel('hours');
%ylabel('Frequency (Hz)');
%zlabel('FFT Amplitude');

if ((!exist('Z'))||(!exist('X')))
	disp('Calculating Z and X');
	fflush(stdout);
	importXCov;
	disp('done');
	fflush(stdout);
endif 

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
componentAmp = dailyModFit(compOut,ZX,designColumns,fullLength);
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
