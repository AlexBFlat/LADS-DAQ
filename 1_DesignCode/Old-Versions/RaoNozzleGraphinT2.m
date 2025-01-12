clear; close all; clc;
Dc = 1.6532;          % Defines chamber diameter in inches.
Rc = Dc/2;
Lcyl = 2.14789559200; % Defines chamber cylinder length in inches.
Dt = 0.3793; % Chamber throat diameter in inches.
Rt = Dt/2;
De = 0.8410; % Defines chamber exit diameter in inches.
Re = De/2;
R1 = 1.5*Dt/2; % Defines R1 fillet.
R2 = 0.9480315; % Chamber to converging fillet radius in inches.
b = 45;         % Nozzle converging angle in degrees.
alpha = 15;
Rn = 0.382*Dt/2; % Nozzle to throat fillet radius in inches.
thetan = 29; % throat to nozzle angle in degrees for an 80% nozzle.
thetae = 9;  % Nozzle exit angle in degrees for an 80% nozzle.
granularity = 12; % Defines number of divisions for each function.

% Function definitions
