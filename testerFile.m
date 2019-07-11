%%%%%%%%%%%%%%%%%%%% PROBLEM LAYOUT & CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Damped oscillator differential equation: x'' + (2wZ) x' + (w^2) x = 0
%Where w is the undamped angular frequency, and Z = 1/2Q. Oscillation is underdamped,
%therefore solution is of the form x = e^(-wZt)[A sin(Ct) + B cos(Ct)]
%C = sqrt[w^2-(wZ)^2] = w*sqrt[1-Z^2]

%torque = kappa*theta + rotI*(d^2 theta/dt^2)

%Pendulum and balance parameters, in SI units:
I = 378/(1e7);                                                                    
f0 = 1.9338e-3; %Fake data f0
%global f0 = 0.0019295; %Real data f0
Q = 500000;                                                                     
Temp = 273+24;  
kappa = (2*pi*f0)^2 * I;

%Sidereal day frequency
omegaEarth = 2*pi*(1/86164.0916);

%Solar day frequency
oED = 2*pi*(1/86400);

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
vernalEqLong = 68.1166667;
%
%%Prepares seattleLat in terms of equatorial cordinates at January 1, 2000 00:00:00 UTC
%%This is the angle of seattleLat from the X vector
%%Additionally converts all angles to radians
seattleLong = ((pi/180)*(degSeattleLong + vernalEqLong)-omegaEarth*6939300);
seattleLat = (pi/180)*degSeattleLat;
compassDir = (pi/180)*degCompassDir;

%%%%%%%%%%%%%%%%%%%% IMPORTING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hourLength = 4096;

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

%Initializes accumulation arrays
divHours = 0;
fullLength = 0;
disp('Reformatting data for analysis');
fflush(stdout);
[divHours,fullLength] = importData(torqueD,hourLength);
disp('done');
fflush(stdout);

%%%%%%%%%%%%%%%%%%%% FFT/OLS ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Performs FFT on each hour length bin
disp('Initial FFT');
fflush(stdout);
[A,B,t] = darkEPFFT(divHours);
disp('done');
fflush(stdout);

%Recovers hour indexing array from importData cell output
tH = cell2mat(divHours(:,2));

%Calculates design matrix, as well as prepares matrix for OLS fitting
disp('Calculating Z and X');
fflush(stdout);
[Z,X,freqVal,numBlocks] = importXCov(rows(divHours),fullLength,tH,hourLength);
ZX = Z*X';
disp('done');
fflush(stdout);

%Collects frequencies from the first FFT fit
shortFreqArray = A(:,1);

%Removes the frequency column and transposes the matrices so that they have hours
%running along the rows
tA = A(:,2:end)';
tB = B(:,2:end)';

%Combining the sin and cos data so that hours are still along the rows but
%halfway the data switches from sin to cos components
Y = zeros(2*rows(tA),columns(tA));
Y = [tA;tB];
%Replicates the data along the rows so that the fit for each intermediate frequency
%is simultaneous.
Y = repmat(Y,numBlocks,1);

%Fitting using precomputed design matrix to find variations in A,B over time
disp('OLS fitting each frequency');
fflush(stdout);
[bMA,bMB] = dailyModFit(Y,ZX,numBlocks);
disp('done');

%Creates frequency array for full length frequency dataset
freqArray = (0:(fullLength/2))'./fullLength;

%Converts complex values to power, applies any necessary transfer functions
disp('Converting freq amplitude to torque power');
fflush(stdout);
pwr = convertToPower(bMA,bMB,kappa,f0,Q,fullLength);
disp('done');
fflush(stdout);

%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
loglog(freqArray,pwr);
title('Z comp Power');
xlabel('Frequency (Hz)');
ylabel('Torque Power');

%!test
%! disp('preCalcComponents');
%! test preCalcComponents
%! disp('importData');
%! test importData
%! disp('importXCov');
%! test importXCov
