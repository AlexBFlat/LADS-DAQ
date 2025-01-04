function [outputtabl, mdot, epsilon] = stationsolvM(gamma,R,Pcns,Tcns,Pe,Mi,F,g,epsilonc)
% Output table initialization
outputtabl = ["Station", "Pressure (Pa)", "Temperature (K)", "Density (kg/m3)", "Velocity (m/s)","Mach number","Area (m^2)","Radius (m)";"Injector", 0, 0, 0, 0, 0, 0, 0;"Nozzle Inlet", 0, 0, 0, 0, 0, 0, 0;"Throat", 0, 0, 0, 0, 0, 0, 0;"Exit", 0, 0, 0, 0, 0, 0, 0];

% Initial solving
rhocns = Pcns/(R*Tcns);

%% Nozzle throat
Mt = 1;                          % Finds mach number at throat.
Pt = Pisen(Pcns,gamma,Mt);       % Finds pressure at throat in Pa.
Tt = Tisen(Tcns,gamma,Mt);       % Finds temperature at throat in K.
rhot = rhoisen(rhocns,gamma,Mt); % Finds density at throat in kg/m3.
at = sqrt(gamma*R*Tt);           % Finds throat speed of sound in m/s.
vt = Mt*at;                      % Finds velocity at throat in m/s.
Cf = sqrt(2*gamma^2/(gamma-1)*(2/(gamma+1))^((gamma+1)/(gamma-1))*(1-(Pe/Pcns)^((gamma-1)/gamma)));
At = F/(Cf*Pcns);                % Finds throat area in m^2.
mdot = rhot*vt*At;               % Finds the flow rate through the engine in kg/m3.
Dt = sqrt(4*At/pi);              % Finds throat diameter in m.

%% Nozzle injector plane
Pinj = Pcns*((1+gamma*Mi^2)/((1+(gamma-1)/2*Mi^2)^(gamma/(gamma-1)))); % Finds pressure for injector plane in psia.
Tinj = Tcns;                      % Finds temperature at injector in K.
rhoinj = rhoisen(rhocns,gamma,0); % Finds injector plane density in kg/m3.
Mc = 0;                           % Finds injector plane mach number.
vinj = 0;                         % Finds velocity at injector plane in m/s.
Ac = At*epsilonc;                 % Finds chamber area in m^2.
Dc = sqrt(4*Ac/pi);               % Finds chamber diameter in m.

%% Nozzle inlet plane
Pi = Pisen(Pcns,gamma,Mi);        % Finds inlet pressure in Pa.
Ti = Tisen(Tcns,gamma,Mi);        % Finds inlet temperature in K.
rhoi = rhoisen(rhocns,gamma,Mi);  % Finds inlet density in kg/m3.
ai = sqrt(gamma*R*Ti);            % Finds inlet speed of sound in m/s.
vi = Mi*ai;                       % Finds inlet velocity in m/s.

%% Nozzle exit plane
Me = Misen(Pcns,Pe,gamma);        % Finds exit mach number.
Te = Tisen(Tcns,gamma,Me);        % Fins exit temperature in K.
rhoe = rhoisen(rhocns,gamma,Me);  % Finds exit density in kg/m3.
ae = sqrt(gamma*R*Te);            % Finds exit speed of sound in m/s.
ve = Me*ae;                       % Finds exit velocity in m/s.
Ae = mdot/rhoe/ve;                % Finds exit area in m^3.
De = sqrt(4*Ae/pi);               % Finds exit diameter in m.

epsilon = Ae/At; % Finds expansion ratio
outputtabl(2,2) = Pinj; outputtabl(2,3) = Tinj; outputtabl(2,4) = rhoinj; outputtabl(2,5) = vinj; outputtabl(2,6) = Mc; outputtabl(2,7) = Ac; outputtabl(2,8) = Dc;
outputtabl(3,2) = Pi; outputtabl(3,3) = Ti; outputtabl(3,4) = rhoi; outputtabl(3,5) = vi; outputtabl(3,6) = Mc; outputtabl(3,7) = Ac; outputtabl(3,8) = Dc;
outputtabl(4,2) = Pt; outputtabl(4,3) = Tt; outputtabl(4,4) = rhot; outputtabl(4,5) = vt; outputtabl(4,6) = Mt; outputtabl(4,7) = At; outputtabl(4,8) = Dt;
outputtabl(5,2) = Pe; outputtabl(5,3) = Te; outputtabl(5,4) = rhoe; outputtabl(5,5) = ve; outputtabl(5,6) = Me; outputtabl(5,7) = Ae; outputtabl(5,8) = De;

%  ||//////////////
%% || Functions //
%  ||////////////

%  Function Pisen solves for the pressure isentropically.
    function Po = Pisen(Pcns,gamma,M)
        Po = Pcns*(1+(gamma-1)/2*M^2)^(-gamma/(gamma-1));
    end

%  Function Tisen solves for the temperature isentropically.
    function Po = Tisen(Tcns,gamma,M)
        Po = Tcns*(1+(gamma-1)/2*M^2)^(-1);
    end

%  Function rhoisen solves for the density isentropically.
    function Po = rhoisen(rhocns,gamma,M)
        Po = rhocns*(1+(gamma-1)/2*M^2)^(-1/(gamma-1));
    end

%  Function Misen solves for the mach number from isentropic pressure
    function M = Misen(Pcns,P,gamma)
        M = sqrt(((P/Pcns)^(-((gamma-1)/gamma))-1)*2/(gamma-1)); % Finds mach number.
    end
end