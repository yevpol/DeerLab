function [err,data,maxerr] = test(opt,oldata)


Ntime = 100;
Ndist = 200;

TimeStep = 0.008;
TimeAxis = linspace(0,TimeStep*Ntime,Ntime);
[~,rmin,rmax] = time2dist(TimeAxis);
DistanceAxis = linspace(rmin,rmax,Ndist);

InputParam = [3 0.5];
Distribution = gaussian(DistanceAxis,InputParam(1),InputParam(2));
Distribution = Distribution/(1/sqrt(2*pi)*1/InputParam(2));
Distribution = Distribution/sum(Distribution)/mean(diff(DistanceAxis));

Kernel = dipolarkernel(TimeAxis,DistanceAxis);
DipEvoFcn = Kernel*Distribution;

InitialGuess = [2 0.1];
[FitDistribution,FitParam] = fitparamodel(DipEvoFcn,Kernel,DistanceAxis,@onegaussian,InitialGuess);
err(1) = any(abs(FitDistribution - Distribution)>1e-5);
err(2) = any(abs(FitParam - InputParam)>1e-3);
err(3)  = length(FitDistribution) < length(DipEvoFcn);
err = any(err);

maxerr = max(abs(FitDistribution - Distribution));
data = [];

if opt.Display
   figure(1),clf,hold on
   plot(TimeAxis,DipEvoFcn,'b')
   plot(TimeAxis,Kernel*FitDistribution,'r')
end

end