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

%importing data
%d = load('fakeDarkEPAugust92017.dat');
d = fData;

%Converts data to torque for fitting
torqueD = internalTorque(d,I,kappa,Q);

divHours = 0;
fullLength = 0;
[divHours,fullLength] = importData(torqueD);

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
