clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
% Injector
Pinj = 2.8958e6;     % Pressure in Pa.
Tinj = 3223.6150;    % Temperature in K.
gammainj = 1.1598;   % Gamma at the injector plane.
densityinj = 2.4032; % Density at the injector plane.
visinj = 1.0405e-4;  % Injector viscosity in kg/ms.
ainj = 1170.6983;    % Sonic velocity in m/s.

% Nozzle inlet
Pcns = 2.8228e6;     % Pressure in Pa.
Tcns = 3218.2576;    % Temperature in K.
gammacns = 1.1596;   % Ratio of specific heats at the nozzle inlet plane.
densitycns = 2.3468; % Density in kg/m3.
visccns = 1.0393;    % Viscosity in kg/ms.
acns = 1169.6060;    % Sonic velocity in m/s.
Mns = 0.1508;        % Nozzle inlet mach number.

% Nozzle throat
Pct = 1.6481e6;    % Throat pressure in pa.
Tct = 3044.4694;   % Temperature at the throat in K.
gammat = 1.1561;   % Gamma at the throat.
densityt = 1.4628; % Density at the throat in kg/m3.
visct = 1.0010e-4; % Viscosity at the throat in kg/m3
at = 1133.2560;    % Sonic velocity at the throat.
Mt = 1;            % Throat mach number.

% Nozzle exit
Pce = 0.1013e6;    % Pressure at the exit in Pa.
Tce = 2103.6377;   % Temperature at the exit in K.
gammae = 1.1953;   % Gamma at the exit.
densitye = 0.1333; % Density at the exit in kg/m3.
visce = 0.7714e-4; % Density at the exit in kg/m3.
ae = 952.8956;     % Sonic velocity at the exit of the nozzle in m/s.
Me = 2.8622;       % Exit mach number.

%% Geometric Constants
% Chamber size
Dc = 19.46e-3;     % Chamber diameter in m.
Dt = 9.73e-3;      % Throat diameter in m.
Lcyl = 245.07e-3;  % Pre-curve chamber length in m.
Lc = 259.34e-3;    % Length of combustion chamber up to throat in m.
Lstar = 1016e-3;   % Characteristic length in m.
R1 = 7.30e-3;      % Chamber-to-throat radius in m.
R2 = 14.05e-3;     % Chamber-to-converging radius in m.
b = 30;            % Chamber-to-converging angle.
AcAt = 4;          % Chamber-to-throat ratio.


% Nozzle size



