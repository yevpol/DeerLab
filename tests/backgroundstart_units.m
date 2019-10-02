function [err,data,maxerr] = test(opt,olddata)

%==============================================================
% Get start of background fit ensure that integer is returned
%==============================================================
%Parameters
k = 0.5;
N = 200;
dt = 0.016;
t = linspace(0,N*dt,N);
%Construct some dipolar evolution function 
r = time2dist(t);
dipevo = dipolarkernel(t,r)*rd_onegaussian(r,[3,0.5]);
%Construct background
bckg = exp(-k*t).';
lam0 = 0.5;
%Account modulation depth for the offset=1
S = (1 - lam0) + lam0*dipevo;
S = S.*bckg;

%us
tstart1 = backgroundstart(S,t,@td_exp);
%ns
t = t*1000;
tstart2 = backgroundstart(S,t,@td_exp);

%Check for errors
err = abs(tstart1 - tstart2)>1e-10;
maxerr = max(abs(tstart1 - tstart2));
data = [];

if opt.Display
    figure(8),clf
    plot(t,bckg,t,Bfit)
end

end