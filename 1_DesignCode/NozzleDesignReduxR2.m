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

%  ||/////////////////////////////////////////
%% || O/F Isp and Tc corellation constants //
%  ||///////////////////////////////////////

%  ||/////////////////
%% || Input values //
%  ||///////////////
%  Design input values
% Engine performance
F = 69;          % Thrust in lb.
%Isp = 261;  % Isp in seconds.
of = 1.1;      % Oxidizer to fuel ratio.
[Tcns, Isp] = OFcor(of);
epsilonc = 22.5;
%epsilonc = 22.5; % Chamber area ratio.
thetacon = 50;   % converging section angle in degrees.
% Engine pressures
Pc = 420;        % Chamber pressure in psia.
Pe = 14.7;       % Exit pressure in psia.
% Engine temperatures
Tco(1) = 273.15; % Initial coolant bulk temperature in K.
%Tcns = 5802.507; % Chamber temperature in R.

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
rhoeth = 789;    % Density of ethanol in kg/m3.

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

%  ||//////////////////////////
%% || Heat transfer         //
%  ||////////////////////////
Au = .00201e-3; Bu = 1614; Cu = .00618; Du = -1.132e-5;
mdotc = mdot/(1+of)/Nc; % Finds channel flowrate in kg/s.
[z,Asz] = size(A);      % Grabs the size of the chamber areas array.
AA = fliplr(A);         % Creates a reversed array of the area throughout the chamber.
AAx = fliplr(Ax);       % Creates a flipped longitudinal position array.
AAy = fliplr(Ay);       % Creates a flipped radius array.
thetac = 360/Nc;  % initializes a theta storage array.
thetacw = zeros(1,Asz); % Initializes wall half-angle array.
thetach = zeros(1,Asz); % Initializes cooled segment angle array.
Ach = zeros(1,Asz);     % Initializes channel area array.
Pch = zeros(1,Asz);     % Initializes channel perimeter array.
dch = zeros(1,Asz);     % Initializes hydraulic diameter array.
vc = zeros(1,Asz);      % Initializes channel velocity array.
Rec = zeros(1,Asz);      % Initializes channel velocity array.
Tco = zeros(1,Asz);      % Initializes channel velocity array.
muc = @(T) Au*exp(Bu/T+Cu*T+Du*T^2); % Function for ethanol viscosity in Pa-s.
syms Twg Twc
Tco(1) = 273.15;
for i = 1:1:Asz
% Area solving
    thetacw(i) = 2*asind(tcw/(4*(AAy(i)+tc))); % Finds channel half-angle in degrees.
    thetach(i) = thetac - 2*thetacw(i);        % Finds cooled segment half angle in degrees.
    Ach(i) = thetach(i)/360*pi*((AAy(i)+tc+wc)^2-(AAy(i)+tc)^2) + wc^2*sind(thetacw(i)); % Finds channel area in m2.
    Pch(i) = 4*pi*thetach(i)/360*(2*AAy(i)+2*tc+wc)+2*wc;                                % Finds channel perimeter in m.
    dch(i) = 4*Ach(i)/Pch(i);                                                            % Finds hydraulic diamter in m.
% Chamber gas solving
    %Taw(i) = 
% Channel flow conditions
    vc(i) = mdotc/(rhoeth*Ach(i)); % Finds channel velocity in m/s.
    Tco(i) = 273.15;
    Rec(i) = rhoeth*vc(i)*dch(i)/muc(Tco(i));
    Prc(i) = 
    %Nuc = @(mu,muw) .027*Rec(i)^.8*Prc
end
thetach = fliplr(thetac);
Ach = fliplr(Ach);
dch = fliplr(dch);
Pch = fliplr(Pch);
vc = fliplr(vc);
Rec = fliplr(Rec);

%  ||//////////////
%% || Plotting  //
%  ||////////////

figure(1);
plot(Ax,Px);
title('Flow properties');
xlabel('Longitudinal position (m)');
ylabel('Pressure (Pa)');
hold on;
yyaxis right;
plot(Ax,Tx);
ylabel('Temperature (K)');
hold off;

figure(2);
plot(Ax,Mx);
title('Flow momentum properties');
xlabel('Longitudinal position (m)');
ylabel('Mach number');
hold on;
yyaxis right;
plot(Ax,vx);
ylabel('Velocity (m/s)');
hold off;

figure(3);
plot(Ax,Ach);
title('Channel geometry properties');
xlabel('Longitudinal position (m)');
ylabel('Channel area (m2)');
hold on;
yyaxis right;
plot(Ax,dch);
ylabel('Hydraulic diameter (m)');
hold off;

figure(4);
plot(Ax,vc);
title('Channel flow characteristics');
xlabel('Longitudinal position (m)');
ylabel('channel velocity (m/s)');
hold on;
yyaxis right;
plot(Ax,Rec);
ylabel('Coolant reynolds number');
hold off;
