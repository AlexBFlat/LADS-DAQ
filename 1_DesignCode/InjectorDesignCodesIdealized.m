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
%d = .5e-3;     % Sets fuel injection hole diameter in m.
%h = .5e-3;     % Sets the oxidizer slot height in m.
wperc = 70;   
% Ethanol Nescius inputs
mdot = 0.2915; % Total engine flowrate, in kg/s.
of = 1.1;      % Oxidizer/Fuel ratio.
Teth = 430;    % Sets ethanol entrance temp in K.
l = 1e-3;      % Orifice depth in m.
%Pcns = 420;    % Chamber pressure in psia.
Pcns = 14.7;
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
mdotff = mdoto/N;                      % Finds film slot flowrate
Pe = Pcns*6894.76;                     % Finds injector exit pressure in Pa.
Pj = Pe*(1+DelP/100);                  % Finds manifold pressure in Pa.
Cdf = .6;
Cdj = .6;


syms hs;
%%% Program solving %%%
rhoeth = 1000; rhoox = 1000; % Sets densities to that of water for testing.
Aj = mdotj/(Cdj*sqrt(2*rhoeth*(Pj-Pe)));
vj = mdotj/(Cdj*rhoeth*Aj);
d = sqrt(Aj/pi);
Af = mdotff/(Cdf*sqrt(2*rhoox*(Pj-Pe)));
vf = mdotff/(Cdf*rhoeth*Af);
Aff = pi*wperc/(400*N)*(hs^2+2*Dp*hs)-Af;
h = max(vpasolve(Aff,hs));
LMR = mdotj*vj/(d/w*mdotf*vf);
TMR = mdotj*vj/(mdotf*vf);
theta = acosd(1/(1+LMR));
fprintf('d: %fmm h: %fmm vj: %fm/s vf: %fm/s LMR: %f TMR: %f Spray angle: %fdegrees\n',d*1000,h*1000,vj,vf,LMR,TMR,theta);