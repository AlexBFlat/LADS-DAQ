%%% Coaxial swirl injector design code %%%
clear; close all; clc;
%%% Engine design values %%%
mdot = .1341; % Total flowrate in kg/s
of = 1.1;      % Oxidizer to fuel ratio
Teth = 509;    % Ethanol inlet temperature in K.
Tox = 90.15;   % Oxygen inlet temperature in K.
Cpox = 918;    % Specific heat of LOX in J/kgK.
%muox = .001;   % Viscosity of oxygen in Pa-s
injstf = 1.15;    % Defines stiffness of injctor.
Pcns = 2895900;% Chamber pressure in psia.
P1eth = Pcns*injstf;
dPeth = P1eth - Pcns;
P1ox = Pcns*injstf;
dPox = 500*6894.76;
Rbin = 4;            % 3 for a closed stage, 0.7-0.8 for open
n1 = 4;              % Number of stage 1 passages.
n2 = 4;              % Number of stage 2 passages.
lbn1 = .5;            % relative nozzle length stage .5.
a1 = 90/2;           % Defines stage one spray angle in degrees.           
a2 = (2*a1-12.5)/2; % Finds alpha2
C = Rbin;
taui = 0.1e-3; % Residence time in seconds.

%%% Calculated design values %%%
muf = mueth(Teth);
Cpf = cpeth(Teth);
rhof = rhoeth(Teth);
muox = 1.80e-5; % Viscosity of liquid oxygen in Pas.
rhoox = 1141; % oxygen density kg/m3.
nuox = muox/rhoox;
nueth = muf/rhof;
mdotox = mdot*of/(of+1);
mdotf = mdot/(of+1);
sigmaw = 0.8e-3; % nozzle wall thickness in m.
vox = 21.28e3; % Vapor pressure of oxygen in Pa.

%% Notes
% a - nondimensional parameter of swirl injector, defined as sqrt(a) = sqrt(2*(1-phi)^2/(2-phi))
%%% Injector design %%%
% Stage 1
%% Step 1 - Determine a, coeff of pass fullness phi, A1, mu1
[A1,muin1] = Afind(a1,lbn1,C);% Finding muin
syms phis;
func1 = A1^2/(1-phis)+1/(phis^2)-(1/muin1)^2;
soln1 = vpasolve(func1);
phi1 = real(max(soln1));
a1 = 2*(1-phi1)^2/(2-phi1);
Rn1 = 0.475*sqrt(mdotox/(muin1*sqrt(rhof*dPeth))); % Nozzle radius for stage 1.
Rin1 = Rbin*Rn1;                                   % Distance from centerline to center of tangential port.
rin1 = sqrt(Rin1*Rn1/(n1*A1));                     % Tangential port radius.
Rs1 = Rin1 + rin1/2;                               % Finds diameter of vortex chamber.
Rein1 = 2*mdotox/(pi*sqrt(n1)*rin1*rhoox*nuox);    % Finds reynolds number. If greater than 10e4, design is converged.
lin1 = 3*rin1;                                     % Length of tangential passages.
ln1 = 2*Rn1;                                       % Nozzle length.
ls1 = 2*Rin1;                                      % Length of vortex chamber.
R1 = Rn1 + sigmaw;                                 % Finds external nozzle radius.

% Stage 2
%% Probably not right! %%
rm2 = [];
Rn2 = [];
mu2 = [];
A2 = [];
rmRn2 = [];
% 1 - Find permitted gas-vortex radius
rm2I = R1+0.3e-3;
% 2 - Assume rm2 = Rn2, find mu using muI = 0.225mdot/(Rn2)...
mu2I = 0.225*mdotf/((rm2I^2)*sqrt(rhof*dPeth));
% 3 - Determine A2 from fig. 34, then rm2 from fig. 35
A2I = Afindfmu(mu2I,C); % Find A2
rmRn2I = rmRn(A2I,Rbin);
rm2(1) = rmRn2I*rm2I;
Rn2(1) = (rm2(1)/rm2I); % Falls apart here - does not worke
mu2(1) = 0.225*mdotf/((Rn2(1)^2)*sqrt(rhof*dPeth));
A2(1) = Afindfmu(mu2(1),C);
rmRn2(1) = rmRn(A2(1),Rbin);
rm2(2) = rmRn2(1)*rm2(1);
converged = 0;
i = 2;
tolerance = 1e-12;
while converged == 0
    Rn2(i) = rm2(i-1)/rm2(i);
    mu2(i) = 0.225*mdotf/((Rn2(i)^2)*sqrt(rhof*dPeth));
    A2(i) = Afindfmu(mu2(i),C);
    rmRn2(i) = rmRn(A2(i),Rbin);
    rm2(i+1) = rmRn2(i)*Rn2(i);
    tolcheck = Rn2(i) - Rn2(i-1);
    if tolcheck <= tolerance
        converged = 1;
    else
        i = i + 1;
    end
end
Rin2 = Rbin*Rn2(i);
rin2 = sqrt((Rin2*Rn2(i))/n2/A2(i));
ln2 = 2*lbn1*Rn2(i);
Rein2 = 2*mdotf/(pi*sqrt(n2)*rin2*rhof*nueth);    % Finds reynolds number. If greater than 10e4, design is converged.
alpha2 = alphafind(A2(i),lbn1);
phi2 = phicalc(A2(i),mu2(i));
phi1 = phicalc(A1,muin1);
lmix = sqrt(2)*taui*((of*mu2(i))/((of+1)*phi2)*sqrt(dPeth/rhof)+muin1/((of+1)*phi1)*sqrt(dPox/rhoox));

fprintf('Rn1: %fmm Rin1: %fmm rin1: %fmm\n',Rn1*1000,Rin1*1000,rin1*1000);
fprintf('ln1: %fmm lin1: %fmm ls1: %fmm\n',ln1*1000,lin1*1000,ls1*1000);
fprintf('Rn2: %fmm Rin2: %fmm rin2: %fmm\n',Rn2(i)*1000,Rin2*1000,rin2*1000);
fprintf('ln2: %fmm lmix: %fmm\n',ln2*1000,lmix*1000);

%%% Functions %%%
function muo = mueth(T)
    Au = .00201e-3; Bu = 1614; Cu = .00618; Du = -1.132e-5; % Constants for finding ethanol viscosity
    muo = Au*exp(Bu/T+Cu*T+Du*T^2);
end

function Cp = cpeth(T)
    Cp = T^4*1.24703e-5+T^3*-.01818+T^2*9.82362+T*-2320.48+204335.2;
end

function rho = rhoeth(T)
    rho = T^2*-.00458+T*2.188704+538.3445;
end

function [A,mu] = Afind(alpha,lnb,C)
    switch lnb
        case 0.5
            C4lnb = 9.40013e-7;
            C3lnb = -.00025;
            C2lnb = 0.02493;
            C1lnb = -1.08898;
            C0lnb = 17.7702;
        case 2
            C4lnb = 7.0917e-6;
            C3lnb = -.00225;
            C2lnb = 0.26769;
            C1lnb = -13.9625;
            C0lnb = 268.7162;
        otherwise
            fprintf('Invalid relative length! Try again.');
            return
    end

    switch C 
        case 1
            C4c = 0.000452103;
            C3c = -.00975;
            C2c = .078702;
            C1c = -.30144;
            C0c = .592322;
        case 4
            C4c = .00057642;
            C3c = -.01241;
            C2c = .097193;
            C1c = -.34916;
            C0c = .663863;
        otherwise
            fprintf('Invalid relative length! Try again.');
            return
    end
    A = (alpha*2)^4*C4lnb+(alpha*2)^3*C3lnb+(alpha*2)^2*C2lnb+(alpha*2)^1*C1lnb+C0lnb;
    mu = A^4*C4c+A^3*C3c+A^2*C2c+A^1*C1c+C0c;
end

function phi = phicalc(A,mu)
    C6 = -811.9*A^7+41785*A^2-34313*A+5412.8;
    C5 = -414*A^7-44353*A^2+45586*A-7995;
    C4 = 621.82*A^7+26017*A^2-30233*A+5781.2;
    C3 = -169.1*A^7-9728*A^2+11003*A-2275;
    C2 = 13.26*A^7+1771.6*A^2-1867*A+444.94;
    C1 = -.167*A^7+-104.2*A^2+104.9*A-36.06;
    C0 = -5e-04*A*7+.027*A^2-0.026*A+1.0033;

    phi = C6*mu^6+C5*mu^5+C4*mu^4+C3*mu^3+C2*mu^2+C1*mu+C0;
end

function rout = rmRn(A,Rin)
    C3 = -.0003046737868848*Rin^4+.0012143998120120*Rin^3+.0014135913355228;
    C2 = 0.0028994521130717*Rin^4 -.0114592023564917*Rin^3-.0326000146763918;
    C1 = -.0071835716999747*Rin^4+0.0278730460823743*Rin^3+0.2340589682357530;
    C0 = 0.0044498600133899*Rin^4-.0193366491486641*Rin^3+.2045080087864870;
    rout = C3*A^3+C2*A^2+C1*A+C0;
end

function A = Afindfmu(mu,C)
switch C 
        case 1
            C4c = 3593.768616;
            C3c = -3967.13;
            C2c = 1613.923;
            C1c = -269.875;
            C0c = 23.22211;
        case 4
            C4c = -1307.8315;
            C3c = 948.4371;
            C2c = -83.0905;
            C1c = -69.8785;
            C0c = 15.02341;
        otherwise
            println('Invalid relative length! Try again.');
            return
      
end

    A = mu^4*C4c+mu^3*C3c+mu^2*C2c+mu^1*C1c+C0c;
end

function mu = mufind(A,C)
    switch C 
        case 1
            C4c = 0.000452103;
            C3c = -.00975;
            C2c = .078702;
            C1c = -.30144;
            C0c = .592322;
        case 4
            C4c = .00057642;
            C3c = -.01241;
            C2c = .097193;
            C1c = -.34916;
            C0c = .663863;
        otherwise
            println('Invalid relative length! Try again.');
            return
    end
    mu = A^4*C4c+A^3*C3c+A^2*C2c+A^1*C1c+C0c;
end

function alpha = alphafind(A,lnb)
    switch lnb
        case 0.5
            C4 = -.45288855;
            C3 = 6.144915;
            C2 = -30.0431;
            C1 = 70.6622;
            C0 = 27.22259;
        case 2
            C4 = -.0970887;
            C3 = 1.865397;
            C2 = -13.0376;
            C1 = 42.01155;
            C0 = 38.32853;
        otherwise
            println('Invalid value on lnb!');
            return
    end
    alpha = (A^4*C4+A^3*C3+A^2*C2+A*C1+C0)/2;
end