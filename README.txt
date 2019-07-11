IMPORTING DATA:

Loads the data, puts it into the array d. Immediately converts the angle data into torque data
using a double derivative, I and kappa in the internalTorque function. Afterwards, using the
hourLength variable, the data is split up into chunks of time of hourLength in a cell array
with the importData function.

[cell array with data, time between first point and last point] = importData(data in torque, hourLength);

This method looks at the difference between times over the modulus with respect to hourLength, hour
divisions either start with zero or a negative difference. Then, by taking diffTime./abs(diffTime) - 1,
only negative values and zero are equal to 1, which will be found by the find function, giving
the indexing array. This function returns the full time length of the data from start to finish, and
the cell array divHours containing the data:

	     	data			time (hours)
divHours	1	torque(1)	1
		2  	toruqe(2)
		3  	torque(3)
		.
		.
		.

		4097	torque(4097)	2
		4098	torque(4098)
		.
		.
		.


FFT/OLS ANALYSIS:

Each hourLength data chunk in divHours will now be converted to FFT values, and the time variation in
the FFT values between each data chunk will be found with an OLS fit. The first FFT gives a shortFreqArray
of 2048 values--corresponding to the positive frequencies from the FFT of each 4096 length data chunk
The OLS fit allows us to find freqeuncies in between those values, so that the final torque with respect
to frequency data has the usual fullLength/2 frequencies and corresponding values.

The first function does the FFT conversion on each hour:

[Array of cos FFT values,Array of sin FFT values, time array of hours] = darkEPFFT(divHours)

Since we know that each chunk in divHours has a length of 4096, the first column can be converted to
a simple matrix, and a reshape operation will make it so that the array has hourLength row entries
corresponding to each point in time during an hour, and the columns correspond to each hour. The FFT
function in octave runs along columns, so to convert each hour chunk to FFT values the FFT can simply
be run on the entire array at once, and taking the real and imaginary parts gives the sin and cos
components.

The next function creates a design matrix so that the time variation over all hours can be found with 
respect to each frequency from the original FFT. 

[Z, X,freqVal,numBlocks] = importXCov(#hour chunks,fullLength,time array(hours), hourLength)
Z = (X'*X)^(-1)		X = design matrix	freqVal = array of intermediate frequencies
between each of the shortFreqArray values	numBlocks = rounded #hours that fit into fullLength


importXCov creates the sparse array design matrix (in index notation):

X(2*numHours*(i-1),2*numHours*i) = [sin(tH*hourLength*2*pi*freqVal(i)),cos(tH*hourLength*2*pi*freqVal(i));...
					-cos(tH*hourLength*2*pi*freqVal(i)),sin(tH*hourLength*2*pi*freqVal(i))];

Where i runs between 1 and numBlocks, and all other values are zero. The reasoning behind this choice of design matrix will be explained in the next function, which performs the OLS fit.

[sin components,cos components] = dailyModFit(Y,ZX = Z*X',numBlocks)
Y is the matrix

Y =			FFT values for each hourLength chunk for each hour run along the columns
			freq = 0(sin)	freq = 1/hourLength	freq = 2/hourLength	...
 	hour = 1	sin component	sin component		sin component		...
	...		...		...			...			...
	hour=numBlocks	sin component	sin component		sin component		...
	hour = 1	cos component	cos component		cos component 		...
	...		...		...			...			...
	hour=numBlocks 	cos component	cos component		cos component		...

and this is copied along the rows numBlocks times, once for each of the intermediate frequencies.

The output is the sin and cos components of the torque with respect to frequency extended to fullLength/2 values,
which is what we want.

Daily mod fit multiplies Z*X'*Y and sorts the terms so that the sin terms of the variation in the FFT
values is in the first column and the cos terms of the variation in the FFT values are in the second column.

The amplitude of the sine and cosine components of the variation are calculated by how much they fit to the
required phase.

Take 	alpha = frequency value from initial FFT fit
	beta  = intermediate frequency value

Each value in the full frequency array is a combination of alpha and beta, and the correct cosine and sine terms
are 

	cos(alpha + beta) = sin(alpha)cos(beta) + cos(alpha)sin(beta)
	sin(alpha + beta) = cos(alpha)cos(beta) - sin(alpha)sin(beta)

This is why the design matrix is formatted the way it is. Each FFT torque sin(alpha) and cos(alpha) is multiplied by
the corresponding beta values, and in the linear fit the term only becomes large if the sin(alpha) and cos(alpha)
terms modulate in this form. By creating a sparse array and duplicating Y along the rows, each beta value can be
fit simultaneously, returning the fullLength/2 torque with respect to frequency output.

**This OLS fitting is not working correctly, each bin seems to have the same repeating frequency variation and gives
a repeating pattern in the plot.

The last function convertToPower takes the sin and cos components and converts to power, applying transfer functions
if necessary--I do not yet have the correct transfer function for the four point double derivative taken to find 
the torque values from the time series data.

APPENDIX:

This section will explain the functionality of other functions that I use in the program

[design matrix] = createSineComponents(time array,input frequency, cM, column selection array)

creates a design matrix with sine and cosine components along the 3 directions, a constant offset component,
a drift component, and some other fitting components. The column selection array makes it so that
the function only returns those columns where cS(column) = 1.

cM is the output of preCalcCompoents--these components apply the correct constants so that the design matrix
accounts for the pendulum being at a certain longitude and latitude.

[cM] = preCalcComponents(time array, latitude, longitude, compass direction angle clockwise from north, start time
in reference to starting julian date)


