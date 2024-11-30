clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
Pcns = 420;          % Chamber stagnation pressure in psi.
Tcns = 5800.752;       % Chamber temperature in R.
OF = 1.5;            % Oxidizer to fuel ratio.
F = 69;              % Thrust in lbs.

% Design Parameters
psi2pa = 6894.76;    % Conversion for psi to pa.
lb2N = 4.448;        % Conversion for lbf to N.
rhoLOX = 1141;       % Liquid Oxygen density in kg/m3.
rhoETH = 789;        % Ethanol density in kg/m3.
g = 32.2;
%gamma = [1.1159 1.1159 1.1525 1.1764];     
gamma = [1.1159 1.1159 1.1159 1.1159];
M = [22.9252 22.9256 23.1886 24.0264];
%M = [22.9252 22.9252 22.9252 22.9252 ];
R = 1544./M;
Mi = .0459;
Pe = 14.7;
etac = 10;
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
Ac = etac*At; % Finds chamber area in in^2.
Pi = Pinj/(1+gammai*Mi^2); % Finds nozzle inlet pressure in psia.
Ti = Pcns/(1+1/2*(gammai-1)*Mi^2); % Finds nozzle inlet temp in R.
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

% Output setting
outputtabl(2,2) = Pinj; outputtabl(2,3) = Tinj; outputtabl(2,4) = Vinj; outputtabl(2,5) = vinj;
outputtabl(3,2) = Pi; outputtabl(3,3) = Ti; outputtabl(3,4) = Vi; outputtabl(3,5) = vi;
outputtabl(4,2) = Pi; outputtabl(4,3) = Ti; outputtabl(4,4) = Vi; outputtabl(4,5) = vi;
