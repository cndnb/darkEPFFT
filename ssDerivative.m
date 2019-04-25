function rtn = ssDerivative(data)
	if(columns(data) !=  1)
		error('symmetric second derivative - too many columns in data array');
	endif
	rtn = [0;0;(-1/12)*(data(1:end-4,1)+data(5:end,1)) + (4/3)*(data(2:end-3,1) + data(4:end-1,1)) + (-5/2)*data(3:end-2,1);0;0];
endfunction
