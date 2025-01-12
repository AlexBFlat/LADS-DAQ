%  ||//////////////////////////////
%% || Initializations and setup //
%  ||////////////////////////////
%  Design input values

clear; close all; clc;
%% Introduction
fprintf(['/////////////////////////////////////\n' ...
         'Parametric Nozzle Design Program ///\n' ...
         'Version: 0.01 Updated: 1/4/2025 ///\n' ...
         '//////////////////////////////////\n'])


%  ||/////////////////
%% || Input values //
%  ||///////////////
%  Design input values
% Engine performance
F = 69;          % Thrust in lb.
Isp = 261;  % Isp in seconds.
of = 1.596;      % Oxidizer to fuel ratio.
epsilonc = 22.5;
%epsilonc = 22.5; % Chamber area ratio.
thetacon = 50;   % converging section angle in degrees.
% Engine pressures
Pc = 420;        % Chamber pressure in psia.
Pe = 14.7;       % Exit pressure in psia.
% Engine temperatures
Tco(1) = 273.15; % Initial coolant bulk temperature in K.
Tcns = 5802.507; % Chamber temperature in R.
% Engine mach numbers
Mi = .0459;      % Sets nozzle inlet mach number.
% Geometric constants
R2rat = 1.5;     % Ratio of R2 to Rt.
Lengthfrac = 80; % Rao nozzle length fraction in percent.
Ndiv = 120;
Nc = 20;         % Number of channels
tc = 1e-3;       % Thickness of chamber wall in meters.
tcw = 1e-3;      % Thickness of channel wall in meters.
wc = 1e-3;       % Channel heigh in meters.
% Environmental constants
g = 9.81;        % Acceleration due to gravity in m/s2.
gamma = 1.1598;  % Gamma of combustion gasses.
M = 22.2429;     % Molar mass of combustion gasses in kmol.
Ro = 8314.36;    % Universal gas constant in J/kmol/K
R = Ro/M;        % Gas constant in J/kgK.
Lstar = 63.27;   % Sets L star in inches, the characteristic nozzle length for ethanol.
Keth = .17;      % Thermal conductivity of ethanol in W/mK.
Kss = 15;        % Thermal conductivity of stainless steel in W/mk.

% Value printing
fprintf(['|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n' ...
         '/////////////////////////////// Design set points ///////////////////////////////\n' ...
         'Thrust: %flb Isp: %fs O/F: %f Contraction ratio: %f\n'],F,Isp,of,epsilonc);

%  ||/////////////////////////////
%% || Initial unit conversions //
%  ||///////////////////////////
% Conversion factors
lb2N = 4.448;  % Conversion factor lbf to N.
Psi2Pa = 6895; % Conversion factor psia to Pa.
in2m = 39.37;  % Conversion factor in to m.
R2K = 5/9;     % Conversion factor R to K.
% Conversions
F = lb2N*F;         % Converts thrust to N.
Pcns = Psi2Pa*Pc;   % Converts chamber pressure to Pa.
Pe = Psi2Pa*Pe;     % Converts exit pressure to Pa.
Tcns = Tcns*R2K;    % Converts chamber temperature to K.
Lstar = Lstar/in2m; % Converts
rhocns = Pcns/R/Tcns;

%  Fluid property import
%py = pyenv(Version="C:\Users\Alex\Desktop\LADS-GIT-Repos\mainenv\Scripts\python.exe");
%Ethanoltables = twoPhaseFluidTables([-215.9,893.96],[0.001,3.0],25,25,60,'Ethanol','py.CoolProp.CoolProp.PropsSI');

%  ||/////////////////////////////
%% || Station solving          //
%  ||///////////////////////////
%  Solves for flow conditions at various stations within the nozzle.
[stat, mdot, epsilon] = stationsolvM(gamma,R,Pcns,Tcns,Pe,Mi,F,g,epsilonc);
Pinj = str2double(stat(2,2)); Tinj = str2double(stat(2,3)); rhoinj = str2double(stat(2,4)); vinj = str2double(stat(2,5)); Mc = str2double(stat(2,6)); Ac = str2double(stat(2,7)); Dc = str2double(stat(2,8));
Pi = str2double(stat(3,2)); Ti = str2double(stat(3,3)); rhoi = str2double(stat(3,4)); vi = str2double(stat(3,5)); Mi = str2double(stat(3,6)); 
Pt = str2double(stat(4,2)); Tt = str2double(stat(4,3)); rhot = str2double(stat(4,4)); vt = str2double(stat(4,5)); Mt = str2double(stat(4,6)); At = str2double(stat(4,7)); Dt = str2double(stat(4,8));
Pe = str2double(stat(5,2)); Te = str2double(stat(5,3)); rhoe = str2double(stat(5,4)); ve = str2double(stat(5,5)); Me = str2double(stat(5,6)); Ae = str2double(stat(5,7)); De = str2double(stat(5,8));

%  ||/////////////////////////////
%% || Geometry solving         //
%  ||///////////////////////////
%  Solves for nozzle geometry.
Vc = Lstar*At; % Finds chamber volume in m3.
syms Lcs;              % Sets the chamber length as a symbolic.
func = At*(Lcs*epsilonc+1/3*sqrt(At/pi)*cotd(thetacon)*(epsilonc^(1/3)-1))-Vc; % Solves for chamber barrel length in m.
Lcyl = real(vpasolve(func));                                                   % Finds chamber length in m.
[F1,F2,F3,F4,F5,F6,P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v,R1] = RaoNozzleGeomMfs(Dc, Dt, De, Lcyl, R2rat, 40, epsilon, Lengthfrac);
[Ax,Ay,A] = chamberplot(P0,P1,P2,P3,P4,P5,P6,F1,F2,F3,F4,F5,F6,1,2,Ndiv);      % Plots chamber area and nozzle profile.

%  ||///////////////////////////////
%% || Isentropic solving         //
%  ||/////////////////////////////
%  Solves isentropically for gas properties throughout the nozzle.

[Px,Tx,rhox,ax,vx,Vx,Dx,Mx] = IsenSolve(A,Ax,gamma,R,Pcns,Tcns,Pt,rhocns,At,mdot); % Solves isentropically for gas properties within the flow throughout the nozzle.

%  ||//////////////
%% || Plotting  //
%  ||////////////

figure(3);
plot(Ax,Px);
title('Flow properties');
xlabel('Longitudinal position (m)');
ylabel('Pressure (Pa)');
hold on;
yyaxis right;
plot(Ax,Tx);
ylabel('Temperature (K)');
hold off;

figure(4);
plot(Ax,Mx);
title('Flow momentum properties');
xlabel('Longitudinal position (m)');
ylabel('Mach number');
hold on;
yyaxis right;
plot(Ax,vx);
ylabel('Velocity (m/s)');
hold off;
