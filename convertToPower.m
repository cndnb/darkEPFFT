function pwr = convertToPower(bA, bB,kappa,resonanceFreq,qFactor,fullLength) %NEEDS TO BE CORRECTED
	%tau = ones(rows(bA),1);
	tau = transferFunction(bA(:,1),kappa,resonanceFreq,qFactor).*twoPointTransfer(bA(:,1),resonanceFreq,1);
	zComp = abs(((bA(:,2).*bB(:,3)) + (bB(:,2).*bA(:,3)))./tau)./fullLength;
	perpX = abs(sqrt(((bA(:,4).*bA(:,5)).^2) + (bB(:,4).*bB(:,5)).^2)./tau)./fullLength;
	paraX = abs(sqrt(((bA(:,6).*bA(:,7)).^2) + (bB(:,6).*bB(:,7)).^2)./tau)./fullLength;
	sumComp = sqrt(zComp.^2 + perpX.^2 + paraX.^2);

	%Return array
	pwr = [bA(:,1),zComp,perpX,paraX,sumComp];
endfunction
