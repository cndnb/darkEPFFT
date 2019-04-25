function rtn = internalTorque(data,I,kappa,Q)
	if(nargin != 4)
		error('rtn = internalTorque(data,I,kappa,Q)');
	endif
	%torque = I*(d^2 theta/dt^2) + kappa*(1+(i/Q))*theta;
	tVal = I*ssDerivative(data(:,2)) + kappa*data(:,1);%(1+(i/Q))*data(:,2);
	rtn = [data(:,1),tVal];
endfunction
