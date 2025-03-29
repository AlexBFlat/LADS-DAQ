%%% Injector Design Code V0.0 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear; clc;

%%% Program Inputs %%% 
% Geometric inputs
Dc = .0667;    % Chamber inner diameter in m.
LsDp = 5;
DelP = 20;     % Injector pressure drop percentage.
%TMR = 1;       % Sets TMR.
N = 20;        % Sets number of pintle holes.
dcdp = 3;      % Sets chamber to pintle diameter ratio.
d = .5e-3;     % Sets fuel injection hole diameter in m.
h = .5e-3;     % Sets the oxidizer slot height in m.
wperc = 70;   
% Ethanol Nescius inputs
mdot = 0.2915; % Total engine flowrate, in kg/s.
of = 1.1;      % Oxidizer/Fuel ratio.
Teth = 430;    % Sets ethanol entrance temp in K.
l = 1e-3;      % Orifice depth in m.
Pcns = 420;    % Chamber pressure in psia.
Pa = 14.7*6894.76; % Atmospheric


%%% Non-user constants %%%
Am = .00201e-3; Bm = 1614; Cm = .00618; Dm = -1.132e-5; % Constants for ethanol viscosity, bvalid 168-516 K.
rhoeth = 637.5; % Ethanol density in kg/m3.
rhoox = 1.429;  % Oxygen density in kg/m3.

%%% Derived program constants %%%
mdotf = mdot/(1+of);  % Derives fuel flowrate in kg/s.
mdoto = mdot - mdotf; % Derives oxygen flowrate in kg/s.
Dp = Dc/(dcdp);       % Finds pintle diameter in m.
C = pi*Dp;
w = (C*wperc)/(N*100);      % Width of a film segment in m.
DP = DelP/100*Pcns*6894.76; % Finds injector pressure drop in Pad.
Pj = Pcns*6894.76+DP;       % Finds injector manifold pressure in Pa.
Ls = LsDp*Dp;

syms vjs;
muf = @(T) Am*exp(Bm/T+Cm*(T)+Dm*T^2);
mueth = muf(Teth);
%%% Program mathematical solution %%%
mdotj = mdotf/N;                       % Finds single jet flowrate in kg/s.
mdotff = mdoto/N;
Pe = Pcns*6894.76;                     % Finds injector exit pressure in Pa.
%Pj = Pe*(1+DelP/100);                  % Finds manifold pressure in Pa.


dmat = linspace(.5e-3,2e-3,15);
hmat = linspace(.5e-3,2e-3,15);
for i = 1:1:15
    d = dmat(i);
    for j = 1:1:15
    h = hmat(j);
    Af(i,j) = pi*wperc/(400*N)*(h^2+2*Dp*h);    % Finds single 
    vf(i,j) = mdoto/(rhoox*Af(i,j));                 % Finds velocity at the film slot.
    Aj = pi*d^2/4;                         % Finds jet area in m2.
    vj(i,j) = mdotff/(rhoeth*Af(i,j));               % Finds jet velocity in m/s.
    LMR(i,j) = mdotj*vj(i,j)/(d/w*mdotff*vf(i,j));
    TMR(i,j) = mdotj*vj(i,j)/(mdotff*vf(i,j));
    J(i,j) = (d/h)^.652*(-.521*exp(-3*LMR(i,j))+.567*exp(-2*LMR(i,j))-.145*exp(-LMR(i,j))+.128);
    Re(i,j) = rhoeth*vj(i,j)*d/mueth;
    Cdo(i,j) = (1/(.868-.0425*sqrt(l/d))+20/Re(i,j)*(1+2.25*(l/d))-(0.005*l/d)/(1+7.5*log(.0015*Re(i,j))^2))^-1;
    Cdj(i,j) = sqrt(Cdo(i,j)^2+((J(i,j)*Cdo(i,j)^2)/LMR(i,j))^2)-J(i,j)*Cdo(i,j)^2/LMR(i,j);
    Pj(i,j) = (mdotj/Cdo(i,j)/Aj)^2/2/rhoeth+Pe;
    delP(i,j) = 100 - Pe/Pj(i,j)*100;
    end
end

figure(1);
plot(dmat,LMR(:,1),dmat,LMR(:,2),dmat,LMR(:,3),dmat,LMR(:,4),dmat,LMR(:,5),dmat,LMR(:,6),dmat,LMR(:,7),dmat,LMR(:,8),dmat,LMR(:,9),dmat,LMR(:,10),dmat,LMR(:,11),dmat,LMR(:,12),dmat,LMR(:,13),dmat,LMR(:,14),dmat,LMR(:,15))
legend('.0005','.0006','.0007','.0008','.0009','.0010','.0011','.0012','.0013','.0014','.0015','.0016','.0017','.0018','.0019','.0020')
title('LMR')

figure(2);
plot(dmat,TMR(:,1),dmat,TMR(:,2),dmat,TMR(:,3),dmat,TMR(:,4),dmat,TMR(:,5),dmat,TMR(:,6),dmat,TMR(:,7),dmat,TMR(:,8),dmat,TMR(:,9),dmat,TMR(:,10),dmat,TMR(:,11),dmat,TMR(:,12),dmat,TMR(:,13),dmat,TMR(:,14),dmat,TMR(:,15))
legend('.0005','.0006','.0007','.0008','.0009','.0010','.0011','.0012','.0013','.0014','.0015','.0016','.0017','.0018','.0019','.0020')
title('TMR')

figure(3);
plot(dmat,Cdo(:,1),dmat,Cdo(:,2),dmat,Cdo(:,3),dmat,Cdo(:,4),dmat,Cdo(:,5),dmat,Cdo(:,6),dmat,Cdo(:,7),dmat,Cdo(:,8),dmat,Cdo(:,9),dmat,Cdo(:,10),dmat,Cdo(:,11),dmat,Cdo(:,12),dmat,Cdo(:,13),dmat,Cdo(:,14),dmat,Cdo(:,15))
legend('.0005','.0006','.0007','.0008','.0009','.0010','.0011','.0012','.0013','.0014','.0015','.0016','.0017','.0018','.0019','.0020')
title('Cdo')

figure(4);
plot(dmat,vj(:,1),dmat,vj(:,2),dmat,vj(:,3),dmat,vj(:,4),dmat,vj(:,5),dmat,vj(:,6),dmat,vj(:,7),dmat,vj(:,8),dmat,vj(:,9),dmat,vj(:,10),dmat,vj(:,11),dmat,vj(:,12),dmat,vj(:,13),dmat,vj(:,14),dmat,vj(:,15))
legend('.0005','.0006','.0007','.0008','.0009','.0010','.0011','.0012','.0013','.0014','.0015','.0016','.0017','.0018','.0019','.0020')
title('Vj')

figure(4);
plot(dmat,delP(:,1),dmat,delP(:,2),dmat,delP(:,3),dmat,delP(:,4),dmat,delP(:,5),dmat,delP(:,6),dmat,delP(:,7),dmat,delP(:,8),dmat,delP(:,9),dmat,delP(:,10),dmat,delP(:,11),dmat,delP(:,12),dmat,delP(:,13),dmat,delP(:,14),dmat,delP(:,15))
legend('.0005','.0006','.0007','.0008','.0009','.0010','.0011','.0012','.0013','.0014','.0015','.0016','.0017','.0018','.0019','.0020')
title('Delp')