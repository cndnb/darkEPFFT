function pwr = convertToPower(betaModA, betaModB,kappa,resonanceFreq,qFactor) %NEEDS TO BE CORRECTED
	tau = transferFunction(betaModA(:,1),kappa,resonanceFreq,qFactor);
	zComp = abs(sqrt((betaModA(:,2).^2) + (betaModA(:,3).^2) + (betaModB(:,2).^2) + (betaModB(:,3).^2))./tau);
	perpX = abs(sqrt((betaModA(:,4).^2) + (betaModA(:,5).^2) + (betaModB(:,4).^2) + (betaModB(:,5).^2))./tau);
	paraX = abs(sqrt((betaModA(:,6).^2) + (betaModA(:,7).^2) + (betaModB(:,6).^2) + (betaModB(:,7).^2))./tau);
	sumComp = abs(sqrt((betaModA(:,2).^2) + (betaModA(:,3).^2) + (betaModB(:,2).^2) + (betaModB(:,3).^2) + (betaModA(:,4).^2) + (betaModA(:,5).^2) + (betaModB(:,4).^2) + (betaModB(:,5).^2) + (betaModA(:,6).^2) + (betaModA(:,7).^2) + (betaModB(:,6).^2) + (betaModB(:,7).^2))./tau);

	%Return array
	pwr = [betaModA(:,1),zComp,perpX,paraX,sumComp];
endfunction
