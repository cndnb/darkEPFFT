function pwr = convertToPower(bA, bB,kappa,resonanceFreq,qFactor) %NEEDS TO BE CORRECTED
	tau = ones(rows(bA),1);
	%tau = transferFunction(bA(:,1),kappa,resonanceFreq,qFactor);
	zComp = abs(((bA(:,2).*bB(:,3)) + (bB(:,2).*bA(:,3)))./tau);
	perpX = abs(sqrt(((bA(:,4).*bA(:,5)).^2) + (bB(:,4).*bB(:,5)).^2)./tau);
	paraX = abs(sqrt(((bA(:,6).*bA(:,7)).^2) + (bB(:,6).*bB(:,7)).^2)./tau);
	sumComp = sqrt(zComp.^2 + perpX.^2 + paraX.^2);

	%Return array
	pwr = [bA(:,1),zComp,perpX,paraX,sumComp];
endfunction
