%'torqueSim'
%test torqueSim

%Make some time
t = 1:1e5; t = t';

%Injected signal parameters
A = 1e-16;
omegaSearch = 2*pi*(sqrt(2))*1e-2;
omegaEarth = 2*pi*(1/86164.0916);

finalSignal = A.*sin(omegaSearch.*t);
%A.*(sin(omegaSearch.*t).*sin(omegaEarth.*t)+cos(omegaSearch.*t).*sin(omegaEarth.*t));
%A.*sin(omegaSearch.*t).*sin(omegaEarth.*t)+A.*cos(omegaSearch.*t).*sin(omegaEarth.*t);


%A*(sin(omegaSearch*t));%+sin(omegaSearch*t).*cos(omegaEarth*t)+sin(omegaSearch*t).*sin(omegaEarth*t));


%Parameters of the experiment
I = 378/1e7;                                                                    
f0 = 1.9338e-3;                                                                 
kappa = ((2*pi*f0)^2)*I;                                                        
Q = 500000;                                                                     
Temp = 0;%273+24; 

%Simulate a pendulum
T= torqueSim(t,I, kappa,Q, Temp, finalSignal);

%Fake some autocollimator noise
AutocollimatorNoise = randn(size(t)) * 0.5e-9;

%Generate measured angle output (THIS IS THE SAME AS THE FAKE DATASET!)
O = [T(:,1) T(:,2) ];%+ AutocollimatorNoise];

%Re-compute torque
Tor = internalTorque(O,I,kappa,Q);

%Checks that peaks are at the correct points
figure(1);
check = psd(Tor);
loglog(check(:,1),check(:,2));

%fullHour = 4096;
%tempO = [O(:,1),O];
%tempO(:,1) = tempO(:,1).-1;
%tempO(:,1) = mod(tempO(:,1),fullHour);
%divHours = cell(0,2);
%lastTime = fullHour;
%hourCount = 0;
%for count = 1:rows(tempO)
%	if (lastTime > tempO(count,1))
%		hourCount = hourCount + 1;
%		divHours{hourCount,2} = hourCount; %Allows recovery of specific time later
%		divHours{hourCount,1} = O(count,:);
%	else
%		divHours{hourCount,1} = [divHours{hourCount,1};O(count,:)];
%	endif	
%	lastTime = tempO(count,1);
%endfor
%
%Makes sure that the division worked correctly 
%fullTimeSeries = [];
%for count = 1:rows(divHours)
%	fullTimeSeries = [fullTimeSeries;divHours{count,1}];
%endfor
%assert(O,fullTimeSeries);
%
%for count = 1:rows(divHours)
%	if (rows(divHours{count,1}) != fullHour)
%		divHours(count,:) = [];
%	endif
%endfor
%fullLength = rows(divHours)*fullHour;

