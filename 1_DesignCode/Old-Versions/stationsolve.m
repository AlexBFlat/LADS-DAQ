function [outputtabl, Wdot, epsilon] = stationsolve(gamma,R,Pcns,Tcns,Pe,Mi,F,Isp,g,epsilonc)
% Nozzle throat plane
gammat = gamma(3);  %
Rt = R(3);
Pt = Pcns*(2/(gammat+1))^((gamma)/(gamma-1)); % Finds throat pressure.
Tt = Tcns*(Pt/Pcns)^((gamma-1)/gamma);        % Finds throat temperature.
Vt = Rt*Tt/144/Pt;                            % Finds throat specific volume in ft3/lbm.
vt = sqrt((2*g*gammat)/(gammat+1)*Rt*Tcns);   % Finds throat velocity in ft/s.
at = sqrt(g*gammat*Rt*Tt);                    % Finds throat speed of sound.
Mt = vt/at;                                   % Checks throat mach number.
Cf = sqrt(2*gamma(1)^2/(gamma(1)-1)*(2/(gamma(1)+1))^((gamma(1)+1)/(gamma(1)-1))*(1-(Pe/Pcns)^((gamma(1)-1)/gamma(1))));
At = F/(Cf*Pcns);                          % Finds throat area in in^2.

outputtabl = ["Station", "Pressure (psia)", "Temperature (R)", "Specific Volume (ft3/lbm)", "Velocity (ft/s)", "Area (in^2)";"Injector", 0, 0, 0, 0, 0;"Nozzle Inlet", 0, 0, 0, 0, 0;"Throat", 0, 0, 0, 0, 0;"Exit", 0, 0, 0, 0, 0];
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
Wdot = F/ve*g;       % Weight flow rate in lbf/s
ae = sqrt(g*gammae*Re*Te); % Finds exit speed of sound.
Me = ve/ae; % Finds exit mach number
IspCHK = ve/g; % Checks Isp.
Ae = 144*Wdot*Ve/ve; % Finds exit area in in^2.
epsilon = Ae/At; % Finds expansion ratio
outputtabl(2,2) = Pinj; outputtabl(2,3) = Tinj; outputtabl(2,4) = Vinj; outputtabl(2,5) = vinj; outputtabl(2,6) = Ac;
outputtabl(3,2) = Pi; outputtabl(3,3) = Ti; outputtabl(3,4) = Vi; outputtabl(3,5) = vi; outputtabl(3,6) = Ac;
outputtabl(4,2) = Pt; outputtabl(4,3) = Tt; outputtabl(4,4) = Vt; outputtabl(4,5) = vt; outputtabl(4,6) = At;
outputtabl(5,2) = Pe; outputtabl(5,3) = Te; outputtabl(5,4) = Ve; outputtabl(5,5) = ve; outputtabl(5,6) = Ae;
end