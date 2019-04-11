%Importing data
%d = load('fakeDarkEPAugust92017.dat');
d = fData;

divHours = 0;
fullLength = 0;
if (!exist('divHours'))
	[divHours,fullLength] = importData(d);
endif

[compOut,t] = darkEPFFT(divHours);
if (!exist('ZX'))
	disp('Calculating Z and X');
	fflush(stdout);
	importXCov;
	disp('done');
	fflush(stdout);
endif 

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
[bMA,bMB] = dailyModFit(compOut,reZX,imZX,designColumns,fullLength);
disp('done');
disp('Converting time amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q,fullLength);
disp('done');
fflush(stdout);


figure(3);
loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4));%,pwr(:,1),pwr(:,5));
title('Torque Power vs. Frequency');
legend('Z','perpX','paraX'); %,'sum');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

figure(4);
loglog(pwr(:,1),pwr(:,2));
title('Z comp Power');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

figure(5);
loglog(pwr(:,1),pwr(:,3));
title('PerpX comp Power');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

figure(6);
loglog(pwr(:,1),pwr(:,4));
title('paraX comp Power');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

%figure(4);
%semilogx(bMA(:,1),bMA(:,2),bMA(:,1),bMA(:,3));
%title('A comp');
%legend('sin','cos');

%figure(5);
%semilogx(bMB(:,1),bMB(:,2),bMB(:,1),bMB(:,3));
%title('B comp');
%legend('sin','cos');

%figure(4);
%semilogx(A(:,1),A(:,2),A(:,1),A(:,3));
%title('A comp');
%legend('sin','cos');

%figure(5);
%semilogx(B(:,1),B(:,2),B(:,1),B(:,3));
%title('B comp');
%legend('sin','cos');
