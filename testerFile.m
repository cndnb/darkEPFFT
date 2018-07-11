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
<<<<<<< HEAD
%
=======

>>>>>>> 331c68e44e5c772eb480c69da69e8b5ba988d897
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
[bMA,bMB] = dailyModFit(compOut,reZX,imZX,designColumns,fullLength);
disp('done');
disp('Converting time amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q);
disp('done');
fflush(stdout);

figure(3);
loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4));
title('Torque Power vs. Frequency');
legend('Z','planeX','sum');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

figure(4);
loglog(bMA(:,1),bMA(:,2),bMA(:,1),bMA(:,3));
title('A comp');
legend('sin','cos');

figure(5);
loglog(bMB(:,1),bMB(:,2),bMB(:,1),bMB(:,3));
title('B comp');
legend('sin','cos');
