clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
% Design Parameters
psi2pa = 6894.76;    % Conversion for psi to pa.
lb2N = 4.448;        % Conversion for lbf to N.
Pcns = 420;          % Chamber stagnation pressure in psi.
Tcns = 5854.57614;       % Chamber temperature in R.
F = 69;              % Thrust in N.
OF = 1.5;            % Oxidizer to fuel ratio.
rhoLOX = 1141;       % Liquid Oxygen density in kg/m3.
rhoETH = 789;        % Ethanol density in kg/m3.
g = 32.2;
gamma = [1.1159 1.1159 1.1525 1.1764];     
M = [22.9252 22.9256 23.1886 24.0264];
R = 1544./M;
Mi = .15;
Pe = 14.7;
etac = 10;

% Calculations
nozvals = nozlsolv(gamma, Pcns, Tcns, R, g, Mi, Pe, F, etac);
Pinj = nozvals(1,1); Tinj = nozvals(1,2); Vinj = nozvals(1,3); vinj = nozvals(1,4);
Pi = nozvals(2,1); Ti = nozvals(2,2); Vi = nozvals(2,3); vi = nozvals(2,4); Ac = nozvals(1,6);
Pt = nozvals(3,1); Tt = nozvals(3,2); Vt = nozvals(3,3); vt = nozvals(3,4); Mt = nozvals(3,5); At = nozvals(3, 6);
Pe = nozvals(4,1); Te = nozvals(4,2); Ve = nozvals(4,3); ve = nozvals(4,4); Me = nozvals(4,5); Ae = nozvals(4, 6);

% Plotting
Chamlinx = [-4 -4];
chamliny = [];


% Function nozlsolv finds most properties within the nozzle.
function out = nozlsolv(gamma, Pcns, Tcns, R, g, Mi, Pe, F, etac)
gammainj = gamma(1);
Rinj = R(1);
Pinj = Pcns*(1+gammainj*Mi^2)/((1+(gammainj-1)/2*Mi^2)^(gammainj/(gammainj-1)));    % Finds injector pressure in psia.
Tinj = Tcns;                                                            % Finds injector temperature in R.
Vinj = (Rinj*Tinj)/(144*Pinj);                                            % Finds injector specific volume in ft3/lbm.
vinj = 0;                                                               % Finds injector velocity, which should be 0.
% Nozzle inlet
gammai = gamma(2);
Ri = R(2);
Pi = Pinj/(1+gammai*Mi^2);                                               % Finds nozzle inlet pressure in psia.
Ti = Tcns/(1+1/2*(gammai-1)*Mi^2);                                       % Finds nozzle inlet temperature in R.
Vi = Ri*Ti/(144*Pi);                                                     % Finds nozzle inlet specific volume in ft3/lbm.
vi = Mi*sqrt(g*gammai*Ri*Ti);                                             % Finds nozzle inlet velocity in ft/s.
% Throat
Rt = R(2);
gammat = gamma(3);
Pt = Pcns*(2/(gammat+1));                                                % Solves for throat pressure in psia.
Tt = Tcns*(Pt/Pcns)^((gammat-1)/gammat);                                  % Finds throat temperature in R.
Vt = sqrt((2*g*gammat)/(gammat+1)*Rt*Tcns);                                % Finds throat specific volume in ft3/lbm.
vt = sqrt(2*g*gammat/(gammat+1)*Rt*Tcns);                                  % Finds throat velocity in ft/s.
Mt = vt/sqrt(g*gammat*Rt*Tt);                                             % Finds throat mach number for checking.
% Exit
gammae = gamma(4);
Re = R(4);
Te = Tcns*(Pe/Pcns)^((gammae-1)/gammae);                                  % Finds exit temperature in R.
Ve = (Re*Te)/(144*Pe);                                                   % Exit specific volume in ft3/lbm.
ve = sqrt((2*g*gammae)/(gammae-1)*Re*Tcns*(1-(Pe/Pcns)^((gammae-1)/gammae)));% Finds exit velocity in ft/s.
Me = ve/sqrt(g*gammae*Re*Te);                                             % Finds exit mach number.
wdot = F*g/ve; 
At = wdot/(Pcns*sqrt((g*gammat*(2/(gammat+1))^((gammat+1)/(gammat-1)))/(Rt*Tcns)));
Ac = etac*At;
eta = ((2/(gammae+1))^(1/(gammae-1))*(Pcns/Pe)^(1/gammae))/sqrt((gammae+1)/(gammae-1)*(1-(Pe/Pcns)^((gammae-1)/gammae)));
Ae = eta*At;
c = ve;
Cf = F/(At*Pcns);
Cstar = sqrt(g*gammae*Re*Tcns)/(gammae*sqrt((2/(gammae+1))^((gammae+1)/(gammae-1))));
Istc = F/wdot;
out = [Pinj Tinj Vinj vinj 0 Ac;Pi Ti Vi vi Mi Ac;Pt Tt Vt vt Mt At;Pe Te Ve ve Me Ae; wdot eta Cf c Cstar Istc];        % Output array.
end

function areas = nozlareas(nozlvals, etac, wdot)
ve = nozlvals(4,4);
Mt = 1;



end


