%%%%%%%%%%%%%%%%%%%% PROBLEM LAYOUT & CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Damped oscillator differential equation: x'' + (2wZ) x' + (w^2) x = 0
%Where w is the undamped angular frequency, and Z = 1/2Q. Oscillation is underdamped,
%therefore solution is of the form x = e^(-wZt)[A sin(Ct) + B cos(Ct)]
%C = sqrt[w^2-(wZ)^2] = w*sqrt[1-Z^2]

%torque = kappa*theta + rotI*(d^2 theta/dt^2)

%Pendulum and balance parameters, in SI units:
global I = 378/(1e7);                                                                    
global f0 = 1.9338e-3; %Fake data f0
%global f0 = 0.0019295; %Real data f0
global Q = 500000;                                                                     
global Temp = 273+24;  
global kappa = (2*pi*f0)^2 * I;

%Sidereal day frequency
global omegaEarth = 2*pi*(1/86164.0916);

%Solar day frequency
global oED = 2*pi*(1/86400);

%Specific pendulum position data
%%Latitude, longitude, and compass direction to be input as decimal degrees
degSeattleLat = 47.6593743;
degSeattleLong = -122.30262920000001;
degCompassDir = 30;
%global dipoleMag = 1;
%
%%Defining the X vector at January 1st 2000 00:00 UTC
%%Using the website https://www.timeanddate.com/worldclock/sunearth.html
%%At the time Mar 20 2000 07:35 UT
%%80*24*3600 + 7*3600 + 35*60 = 6939300 seconds since January 1, 2000 00:00:00 UTC
%%At the vernal equinox, longitude is equal to zero, so z=0;
global vernalEqLong = 68.1166667;
%
%%Prepares seattleLat in terms of equatorial cordinates at January 1, 2000 00:00:00 UTC
%%This is the angle of seattleLat from the X vector
%%Additionally converts all angles to radians
seattleLong = ((pi/180)*(degSeattleLong + vernalEqLong)-omegaEarth*6939300);
seattleLat = (pi/180)*degSeattleLat;
compassDir = (pi/180)*degCompassDir;

%%%%%%%%%%%%%%%%%%%% IMPORTING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%importing data
%d = load('fakeDarkEPAugust92017.dat');

d = fData;
%d = torsionFilter(fData(:,1),fData(:,2),1/f0);
d(:,2) = d(:,2) - mean(d(:,2));

%Converts data to torque for fitting
disp('Converting data to torque');
fflush(stdout);
torqueD = internalTorque(d,I,kappa,Q);
disp('done');
fflush(stdout);


divHours = 0;
fullLength = 0;
disp('Reformatting data for analysis');
fflush(stdout);
[divHours,fullLength] = importData(torqueD);
disp('done');
fflush(stdout);

%%%%%%%%%%%%%%%%%%%% FFT/OLS ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Initial FFT');
fflush(stdout);
[A,B,t] = darkEPFFT(divHours);
disp('done');
fflush(stdout);

disp('Calculating Z and X');
fflush(stdout);
importXCov;
disp('done');
fflush(stdout);

shortFreqArray = A(:,1);
tA = A(:,2:end)';
tB = B(:,2:end)';
Y = zeros(2*rows(tA),columns(tA));
for count = 1:columns(tA)
	Y(:,count) = [tA(:,count);tB(:,count)];
endfor
Y = repmat(Y,numBlocks,1);

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
[bMA,bMB,freqArray] = dailyModFit(Y,ZX,numBlocks,designColumns,numHours,fullLength,A(2,1)-A(1,1),freqVal,shortFreqArray);
disp('done');

disp('Converting freq amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q,fullLength);
disp('done');
fflush(stdout);

%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%figure(3);
%loglog(pwr(:,1),pwr(:,2),pwr(:,1),pwr(:,3),pwr(:,1),pwr(:,4));%,pwr(:,1),pwr(:,5));
%title('Torque Power vs. Frequency');
%legend('Z','perpX','paraX'); %,'sum');
%xlabel('Frequency (Hz)');
%ylabel('Torque Power');

figure(4);
loglog(freqArray,pwr);
title('Z comp Power');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

%figure(5);
%loglog(pwr(:,1),pwr(:,3));
%title('PerpX comp Power');
%xlabel('Frequency (Hz)');
%ylabel('Torque Power');

%figure(6);
%loglog(pwr(:,1),pwr(:,4));
%title('paraX comp Power');
%xlabel('Frequency (Hz)');
%ylabel('Torque Power');

