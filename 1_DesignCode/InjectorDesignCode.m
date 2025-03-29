%%% Injector Design Code V0.0 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; clear; clc;

%%% Program Inputs %%% 
% Geometric inputs
Dc = .0667;    % Chamber inner diameter in m.
LsDp = 1;
DelP = 20;     % Injector pressure drop percentage.
TMR = 1;       % Sets TMR.
N = 20;        % Sets number of pintle holes.
dcdp = 3;      % Sets chamber to pintle diameter ratio.
% Ethanol Nescius inputs
mdot = 0.2915; % Total engine flowrate, in kg/s.
of = 1.1;      % Oxidizer/Fuel ratio.
Teth = 430;    % Sets ethanol entrance temp in K.
l = 1e-3;      % Orifice depth in m.
Pcns = 420*6894.76;    % Chamber pressure in psia.
Pa = 101325; % Atmospheric

%%% Non-user constants %%%
Am = .00201e-3; Bm = 1614; Cm = .00618; Dm = -1.132e-5; % Constants for ethanol viscosity, bvalid 168-516 K.
rhoeth = 637.5; % Ethanol density in kg/m3.
rhoox = 1.429;  % Oxygen density in kg/m3.

%%% Derived program constants %%%
mdottf = mdot/(1+of);  % Derives fuel flowrate in kg/s.
mdotto = mdot - mdottf; % Derives oxygen flowrate in kg/s.
Dp = Dc/(dcdp);       % Finds pintle diameter in m.
w = 2*pi*(Dc/2)/N;    % Width of a film segment in m.
DP = DelP/100*Pcns; % Finds injector pressure drop in Pad.
Pj = Pcns+DP;       % Finds injector manifold pressure in Pa.
Ls = LsDp*Dp;

%%% Program mathematical functions %%%
Cdof = @(Re,l,d) (1/(0.868-.0425*sqrt(l/d))+20/Re*(1+2.25*l/d)-0.005*l/d/(1+7.5*(log(.0015)*Re)^2))^-1;
Cdjf = @(Cdo,J,LMR) sqrt(Cdo^2+(J*Cdo^2/LMR)^2)-J*Cdo^2/LMR;
Jf = @(h,d,LMR) (d/h)^.652*(-.521*exp(-3*LMR)+.567*exp(-2*LMR)-.145*exp(-LMR)+.128);
Ref = @(rho,v,D,mu) rho*v*D/mu;
muf = @(T) Am*exp(Bm/T+Cm*(T)+Dm*T^2);
LMRf = @(mdotj,mdotf,vj,vf,d,w) mdotj*vj/(d/w*mdotf*vf);
TMRf = @(mdotj, vj, mdotf, vf) mdotj*vj/mdotf/vf;
vjf = @(mdotj, N, Dp, rhoeth,h) 4*mdotj/((pi/N*((Dp/2+h)^2-(Dp/2)^2))*rhoeth);
Aff = @(h) pi/N*((Dp/2+h)^2-(Dp/2)^2);
vff = @(Af) 4*mdotto/N/(Af*rhoox);


%%% Program Solving %%%
syms hs ds;
mdotj = mdottf/N; % Finds single orifice jet flowrate in kg/s.
mdotf = mdotto/N; % Finds single segment of oxidizer film flowrate in kg/s.
Aj = pi*ds^2/4;
Afs = pi/N*((Dp/2+hs)^2-(Dp/2)^2);
vj = mdotj/(Aj*rhoeth);
vfs = mdotf/(Afs*rhoox);
LMRs = mdotj*vj/(ds/2*mdotf*vfs);
Js = (ds/hs)^.652*(-.521*exp(-3*LMRs)+.567*exp(-2*LMRs)-.145*exp(-LMRs)+.128);
Re = rhoeth*ds*vj/muf(Teth);
Cdos = (1/(0.868-.0425*sqrt(l/ds))+20/Re*(1+2.25*l/ds)-0.005*l/ds/(1+7.5*(log(.0015)*Re)^2))^-1;
Cdjs = sqrt(Cdos^2+((Js*Cdos^2)/LMRs)^2)-Js*Cdos^2/LMRs;
f1 = Cdos*Aj*sqrt(2*rhoeth*(Pj-Pcns))-mdotj;
f2 = Cdjs*Aj*sqrt(2*rhoeth*(Pj-Pa))-mdotj;
[h, d] = vpasolve([f1,f2],[hs,ds]);
h = real(h);
d = real(d);
%theta = acosd(1/(1+LMRf(mdotj,mdotf,vjf(mdotj,N,Dp,rhoeth,h),vff(Aff(h)),d,w)));
%LMR = LMRf(mdotj,mdotf,vjf(mdotj,N,Dp,rhoeth,h),vff(Aff(h)),d,w);
fprintf('h: %fmm d: %fmm\n',h*10^(3),d*10^3);
