t = (1:100000)';

alpha = 1/30;
beta = 1/100;
Amp = 1e-15;

A = Amp.*sin((alpha+beta).*t);


X1 = [sin(alpha.*t)];
X2 = [cos(beta*t)];
[b1,s1,R1,err1,Cov1] = ols2(A,X1);
[b2,s2,R2,err2,Cov2] = ols2(A,X2);

assert(b1*b2,Amp);