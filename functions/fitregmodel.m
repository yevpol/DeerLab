% 
% FITREGMODEL Fits a parameter-free distance distribution to one (or several)
%             time-domain signals, using regularization
%
%   P = FITREGMODEL(V,K,r,regtype,alpha)
%   Regularization of the N-point signal (V) to a M-point distance
%   distribution (P) given a M-point distance axis (r) and NxM point kernel
%   (K). The regularization parameter (alpha) controls the regularization 
%   properties.
%
%   P = FITREGMODEL(V,K,r,regtype,method)
%   Instead of passing a numerial value for the regularization parameter
%   (alpha), the name of a selection method (method) can be passed and 
%   the regularization parameter will be automatically selected by means
%   of the selregparam function.
%
%
%   The type of regularization employed in FITREGMODEL is set by the regtype
%   input argument. The regularization models implemented in FITREGMODEL are:
%          'tikhonov' -   Tikhonov regularization
%          'tv'       -   Total variation regularization
%          'huber'    -   pseudo-Huber regularization
%
%   P = FITREGMODEL({V1,V2,...},{K1,K2,...},r,regtype,alpha)
%   Passing multiple signals/kernels enables global fitting of the
%   a single-distribution model to all data. The global fit weights
%   are automatically computed according to their contribution to ill-posedness.
%
%   P = FITREGMODEL(...,'Property',Values)
%   Additional (optional) arguments can be passed as property-value pairs.
%
% The properties to be passed as options can be set in any order. 
%
%   'Solver' - Solver to be used to solve the minimization problems
%                      'fnnls' - Fast non-negative least-squares
%                      'lsqnonneg' - Non-negative least-squares 
%                      'fmincon' - Non-linear constrained minimization
%                      'bppnnls' -  Block principal pivoting non-negative least-squares solver
%
%   'NonNegConstrained' - Enable/disable non-negativity constraint (true/false)
%
%   'HuberParam' - Huber parameter used in the 'huber' model (default = 1.35).
%
%   'GlobalWeights' - Array of weighting coefficients for the individual signals in
%                     global fitting.
%
%   'RegOrder' - Order of the regularization operator L (default = 2).
%
%   'TolFun' - Optimizer function tolerance
%
%   'MaxIter' - Maximum number of optimizer iterations
%
%   'MaxFunEvals' - Maximum number of optimizer function evaluations   
%
%   'Verbose' - Display options for the solvers:
%                    'off' - no information displayed  
%                    'final' - display solver exit message
%                    'iter-detailed' - display state of solver at each iteration                   iteration
%                     See MATLAB doc optimoptions for detailed explanation
%
% This file is a part of DeerLab. License is MIT (see LICENSE.md). 
% Copyright(c) 2019-2020: Luis Fabregas, Stefan Stoll and other contributors.


function [P,alpha] = fitregmodel(V,K,r,RegType,alpha,varargin)

% Turn off warnings to avoid ill-conditioned warnings 
warning('off','MATLAB:nearlySingularMatrix')

%--------------------------------------------------------------------------
% Parse & Validate Required Input
%--------------------------------------------------------------------------
if nargin<3
    error('Not enough input arguments.')
end
if nargin<4 || isempty(RegType)
    RegType = 'tikhonov';
elseif isa(RegType,'function_handle')
    RegFunctional = RegType;
    RegType = 'custom';
else
    validateattributes(RegType,{'char'},{'nonempty'})
    allowedInput = {'tikhonov','tv','huber','custom'};
    RegType = validatestring(RegType,allowedInput);
end
if  nargin<5 || isempty(alpha)
   alpha = 'aic'; 
end

% Check if user requested some options via name-value input
optionalProperties = {'TolFun','Solver','NonNegConstrained','Verbose','MaxFunEvals','MaxIter','HuberParam','GlobalWeights','RegOrder','internal::parseLater'};
[TolFun,Solver,NonNegConstrained,Verbose,MaxFunEvals,MaxIter,HuberParam,GlobalWeights,RegOrder] ...
    = parseoptional(optionalProperties,varargin);


% Remove used options from varargin so they are not passed to selregparam
for i=1:numel(optionalProperties)
    Idx = find(cellfun(@(x)(ischar(x) && strcmpi(x,optionalProperties{i})),varargin));
    varargin(Idx:Idx+1) = [];
end

if strcmp(RegType,'custom')
    GradObj = false;
else
    GradObj = true;
end
if isa(alpha,'char')
    alpha = selregparam(V,K,r,RegType,alpha,[{'GlobalWeights'},{GlobalWeights},varargin]);
else
    validateattributes(alpha,{'numeric'},{'scalar','nonempty','nonnegative'},mfilename,'RegParam')
end
% validateattributes(r,{'numeric'},{'nonempty','increasing','nonnegative'},mfilename,'r')
validateattributes(r,{'numeric'},{'nonempty','nonnegative'},mfilename,'r')

%--------------------------------------------------------------------------
% Parse & Validate Optional Input
%--------------------------------------------------------------------------

if isempty(Verbose)
    Verbose = 'off';
else
    validateattributes(Verbose,{'char'},{'nonempty'},mfilename,'Verbose')
end

if isempty(RegOrder)
    RegOrder = 2;
else
    validateattributes(RegOrder,{'numeric'},{'scalar','nonnegative'})
end
if isempty(TolFun)
    TolFun = 1e-9;
else
    validateattributes(TolFun,{'numeric'},{'scalar','nonempty','nonnegative'},'regularize','nonNegLSQsolTol')
end
if isempty(Solver) && ~strcmp(RegType,'custom')
    Solver = 'fnnls';
elseif isempty(Solver) && strcmp(RegType,'custom')
        Solver = 'fmincon';
else
    validateattributes(Solver,{'char'},{'nonempty'})
    allowedInput = {'analytical','fnnls','lsqnonneg','bppnnls','fmincon'};
    Solver = validatestring(Solver,allowedInput);
end

if isempty(MaxIter)
    MaxIter = 2e7;
else
    validateattributes(MaxIter,{'numeric'},{'scalar','nonempty'},mfilename,'MaxIter')
end

if isempty(HuberParam)
    HuberParam = 1.35;
else
    validateattributes(HuberParam,{'numeric'},{'scalar','nonempty','nonnegative'},mfilename,'MaxFunEvals')
end

if isempty(MaxFunEvals)
    MaxFunEvals = 2e7;
else
    validateattributes(MaxFunEvals,{'numeric'},{'scalar','nonempty'},mfilename,'MaxFunEvals')
end

if isempty(NonNegConstrained)
    NonNegConstrained = true;
else
    validateattributes(NonNegConstrained,{'logical'},{'nonempty'},'regularize','NonNegConstrained')
end
if ~iscell(V)
    V = {V};
end
if ~iscell(K)
    K = {K};
end
if ~isempty(GlobalWeights)
    validateattributes(GlobalWeights,{'numeric'},{'nonnegative'})
    if length(GlobalWeights) ~= length(V)
        error('The same number of global fit weights as signals must be passed.')
    end
    % Normalize weights
    GlobalWeights = GlobalWeights/sum(GlobalWeights);
end
if numel(K)~=numel(V)
    error('The number of kernels must be equal to the number of kernels.')
end
for i = 1:numel(V)
    if ~iscolumn(V{i})
        V{i} = V{i}.';
    end
    if ~isreal(V{i})
        V{i} = real(V{i});
    end
    if length(V{i})~=size(K{i},1)
        error('The number of rows in K must match the number of elements in V.')
    end
    validateattributes(V{i},{'numeric'},{'nonempty'},mfilename,'S')
end

%--------------------------------------------------------------------------
% Regularization processing
%--------------------------------------------------------------------------

nr = size(K{1},2);
L = regoperator(nr,RegOrder);
InitialGuess = zeros(nr,1);

dr = mean(diff(r));

% If unconstrained regularization is requested then solve analytically
if ~NonNegConstrained && ~strcmp(Solver,'fmincon')
    Solver = 'analytical';
end

% If using LSQ-based solvers then precompute the KtK and KtS input arguments
if ~strcmp(Solver,'fmincon')
    [Q,KtS,weights] =  lsqcomponents(V,r,K,L,alpha,RegType,HuberParam,GlobalWeights);
end

% Solve the regularization functional minimization problem
switch lower(Solver)
    
    case 'analytical'
        P = zeros(nr,1);
        for i = 1:length(V)
            PseudoInverse = Q\K{i}.';
            P = P + weights(i)*PseudoInverse*V{i};
        end
        
    case 'lsqnonneg'
        solverOpts = optimset('Display','off','TolX',TolFun);
        P = lsqnonneg(Q,KtS,solverOpts);

    case 'fnnls'
        [P,~,~,flag] = fnnls(Q,KtS,InitialGuess,TolFun,Verbose);
        %In some cases, fnnls may return negatives if tolerance is to high
        if flag==-1
            %... in those cases continue from current solution
            [P,~,~,flag] = fnnls(Q,KtS,P,1e-20);
        end
        if flag==-2
            warning('FNNLS cannot solve the problem. Regularization parameter may be too large.')
        end
        
    case 'bppnnls'
        P = nnls_bpp(Q,KtS,Q\KtS);
        
    case 'fmincon'
        % Constrained Tikhonov/Total variation/Huber regularization
        if NonNegConstrained
            NonNegConst = zeros(nr,1);
        else
            NonNegConst = [];
        end
        if ~strcmp(RegType,'custom')
            RegFunctional = regfunctional(RegType,V,L,K,alpha,HuberParam);
        else
        %Parse errors in the analyzed function, and reformat them
        RegFunctional = @(P)errorhandler(RegFunctional,'regfcn',P);
        end
        
        fminconOptions = optimoptions(@fmincon,'SpecifyObjectiveGradient',GradObj,'MaxFunEvals',MaxFunEvals,'Display',Verbose,'MaxIter',MaxIter);
        [P,~,exitflag] =  fmincon(RegFunctional,InitialGuess,[],[],[],[],NonNegConst,[],[],fminconOptions);
        % Check how optimization exited...
        if exitflag == 0
            %... if maxIter exceeded (flag=0) then double iterations and continue from where it stopped
            fminconOptions = optimoptions(fminconOptions,'MaxIter',2*MaxIter,'MaxFunEvals',2*MaxFunEvals);
            P  = fmincon(RegFunctional,P,[],[],[],[],NonNegConst,[],[],fminconOptions);
        end
end

% Normalize distribution
P = P/sum(P)/dr;

% Turn warnings back on
warning('on','MATLAB:nearlySingularMatrix')

end
