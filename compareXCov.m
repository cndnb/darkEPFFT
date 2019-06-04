
hourLength = 4096;
t=1:1e5; t=t';
fData = [t,randn(rows(t),1)];
numHours = floor(rows(fData)/hourLength);
tH = (1:numHours)';
[Z,X,freqVal,numBlocks] = importXCov(numHours,rows(fData),tH,hourLength);
signMat = [ones(numHours,1),-1.*ones(numHours,1);ones(numHours,1),ones(numHours,1)];
cS = [1,1,0,0,0,0,0,0,0,0];
for count = 1:numBlocks
	littleX = signMat.*[createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS);fliplr(createSineComponents(hourLength.*tH,2*pi*freqVal(count,1),ones(numHours,3),cS))];
	assert(Z(2*count-1:2*count,2*count-1:2*count), inv(littleX'*littleX),2*eps);
endfor

ZX = Z*X'; 
count = 1;
	preData = exp((2*pi*i*freqVal(count)*hourLength).*tH);
	doubleData = [real(preData);imag(preData)];
	checkData = repmat(doubleData,numBlocks,1);
	BETA = ZX*checkData;
	expectedBETA = zeros(rows(BETA),1);
	expectedBETA(2*count-1:2*count,1) = ones(2,1);
	assert(BETA,expectedBETA);

