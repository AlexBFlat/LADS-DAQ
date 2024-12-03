clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
Pcns = 420;          % Chamber stagnation pressure in psi.
Tcns = 5802.507;       % Chamber temperature in R.
OF = 1.5;            % Oxidizer to fuel ratio.
F = 69;              % Thrust in lbs.

% Design Parameters
psi2pa = 6894.76;    % Conversion for psi to pa.
lb2N = 4.448;        % Conversion for lbf to N.
rhoLOX = 1141;       % Liquid Oxygen density in kg/m3.
rhoETH = 789;        % Ethanol density in kg/m3.
g = 32.2;
%gamma = [1.1598 1.1598 1.1561 1.1955];     
gamma = [1.1598 1.1598 1.1598 1.1598];
M = [22.2429 22.2432 22.4689 23.0151];
%M = [22.2429 22.2429 22.2429 22.2429 ];
R = 1544./M;
Mi = .0459;
Pe = 14.7;
epsilonc = 19;
Isp = 252.5994;     % Theoretical Isp in s.

%% Solving
Wdot = F/Isp;       % Weight flow rate in lbf/s
% Nozzle throat plane
gammat = gamma(3);
Rt = R(3);
Pt = Pcns*(2/(gammat+1))^((gamma)/(gamma-1)); % Finds throat pressure.
Tt = Tcns*(Pt/Pcns)^((gamma-1)/gamma);        % Finds throat temperature.
Vt = Rt*Tt/144/Pt;                            % Finds throat specific volume in ft3/lbm.
vt = sqrt((2*g*gammat)/(gammat+1)*Rt*Tcns);   % Finds throat velocity in ft/s.
at = sqrt(g*gammat*Rt*Tt);                    % Finds throat speed of sound.
Mt = vt/at;                                   % Checks throat mach number.
At = 144*Wdot*Vt/vt;                          % Finds throat area in in^2.

outputtabl = ["Station", "Pressure (psia)", "Temperature (R)", "Specific Volume (ft3/lbm)", "Velocity (ft/s)";"Injector", 0, 0, 0, 0;"Nozzle Inlet", 0, 0, 0, 0;"Throat", 0, 0, 0, 0;"Exit", 0, 0, 0, 0];
% Nozzle injector plane
gammainj = gamma(1); % Selects gamma for injector plane.
Rinj = R(1);         % Selects R for injector plane.
Pinj = Pcns*((1+gammainj*Mi^2)/((1+(gammainj-1)/2*Mi^2)^(gammainj/(gammainj-1)))); % Finds pressure for injector plane in psia.
Tinj = Tcns;            % Finds injector temp.
Vinj = Rinj*Tinj/144/Pinj; % Finds injector specific volume.
vinj = 0;
% Nozzle inlet plane
gammai = gamma(2);
Ri = R(2);
Ac = epsilonc*At; % Finds chamber area in in^2.
Pi = Pinj/(1+gammai*Mi^2); % Finds nozzle inlet pressure in psia.
Ti = Tinj/(1+1/2*(gammai-1)*Mi^2); % Finds nozzle inlet temp in R.
Vi = Ri*Ti/(144*Pi);               % Finds nozzle inlet specific volume.
ai = sqrt(g*gammai*Ri*Ti);
vi = Mi*ai;

% Nozzle exit plane
gammae = gamma(4);
Re = R(4);
Te = Tcns*(Pe/Pcns)^((gamma-1)/gamma); % Finds exit temp.
Ve = Re*Te/144/Pe;                     % Finds exit specific volume.
ve = sqrt(2*g*gammae/(gammae-1)*Re*Tcns*(1-(Pe/Pcns)^((gamma-1)/gamma))); % Finds exit velocity in ft/s
ae = sqrt(g*gammae*Re*Te); % Finds exit speed of sound.
Me = ve/ae; % Finds exit mach number
IspCHK = ve/g; % Checks Isp.
Ae = 144*Wdot*Ve/ve; % Finds exit area in in^2.
epsilon = Ae/At; % Finds expansion ratio

ts = 1.4706e-3;

% Chamber sizing
Vavg = median([Vinj Vi]); % Finds chamber average specific volume in ft3/lb.
Vc = Wdot*Vavg*ts; % Finds chamber volume in square feet.
Vcin = Vc*12^3;    % Finds chamber volume in square inches.
Lstar = Vcin/At;     % Finds Lstar in inches.
syms Lc;
theta = 45;
func = At*(Lc*epsilonc+1/3*sqrt(At/pi)*cotd(theta)*(epsilonc^(1/3)-1))-Vcin; % Solves for chamber barrel length in inches.
Lc = vpasolve(func); % Finds chamber length in inches.
epsiloncG = linspace(2, 20);
Lcvals = (Vcin./At - 1/3.*sqrt(At./pi).*cotd(theta).*(epsiloncG.^(1/3)-1))./epsiloncG;
Dc = 2*sqrt(Ac/pi);
Dt = 2*sqrt(At/pi);
De = 2*sqrt(Ae/pi);
Lcon = tan(theta)*((Dc-Dt)/2);
Lct = Lcon + Lc; % Total combustion chamber length in in.

% Output setting
outputtabl(2,2) = Pinj; outputtabl(2,3) = Tinj; outputtabl(2,4) = Vinj; outputtabl(2,5) = vinj;
outputtabl(3,2) = Pi; outputtabl(3,3) = Ti; outputtabl(3,4) = Vi; outputtabl(3,5) = vi;
outputtabl(4,2) = Pt; outputtabl(4,3) = Tt; outputtabl(4,4) = Vt; outputtabl(4,5) = vt;
outputtabl(5,2) = Pe; outputtabl(5,3) = Te; outputtabl(5,4) = Ve; outputtabl(5,5) = ve;
fprintf('Isp error: %f(s)\n',IspCHK-Isp);

% Plotting
figure(1);
plot(epsiloncG, Lcvals);
title('Chamber length versus chamber area ratio');
xlabel('Chamber area ratio');
ylabel('Chamber length (in)');
figure(2);
% Chamber plotting




% Conical nozzle plotting
alpha = 15;
Ln = (De-Dt)/(2*tand(alpha));
Lnx = linspace(0,Ln,6);
Lny = (De-Dt)./(2.*Ln).*Lnx+Dt/2;
R1 = 1.5*Dt/2;
b = 0.5*Dt + R1;
a = 0;
syms xf1f2
f1f2FUNC = -xf1f2/sqrt(R1^2-xf1f2^2)+(Dt-Dc)/(2*Lcon);
xf1f2sol = solve(f1f2FUNC);
R1x = linspace(xf1f2sol, 0,12);
R1y = -sqrt(R1^2-(abs(R1x)-a).^2)+b;

Lcx = linspace(-Lct+xf1f2sol, -Lcon+xf1f2sol, 6);
Lcy = linspace(Dc/2,Dc/2,6);
P1conx = -Lcon+xf1f2sol;
P1cony = Dc/2;
P2conx = xf1f2sol;
P2cony = R1y(1);
Lconx = linspace(-Lcon+xf1f2sol, xf1f2sol, 6);
mcon = (P2conx-P1conx)/(P2cony-P1cony);
bcon = P1cony-P1conx*mcon;
%Lcony = -(Lconx+.15)*(Dc/2-Dt/2)/Lcon+Dt/2;
Lcony = mcon.*Lconx;

centx = linspace(-Lct, Ln,6);
centy = linspace(0, 0, 6);
plot(centx,centy,'r--',Lcx, Lcy,'g',Lcx, -Lcy,'g',Lconx,Lcony,'g' ,Lconx, -Lcony,'g' ,Lnx, Lny,'g' ,Lnx, -Lny,'g',R1x,R1y);
fprintf('Chamber length: %fin\nChamber diameter:%fin\n',Lc,Dc);
fprintf('P1x: %d P1y: %d\nP2x: %d P2y:%d\n',P1conx,P1cony,double(P2conx),double(P2cony));