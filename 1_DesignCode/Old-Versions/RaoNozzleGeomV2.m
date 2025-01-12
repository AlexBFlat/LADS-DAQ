%clear; close all; clc;
Dc = 1.6532;          % Defines chamber diameter in inches.
Dt = 0.3793;          % Chamber throat diameter in inches.
De = 0.8410;          % Defines chamber exit diameter in inches.
Lcyl = 2.14789559200; % Defines chamber cylinder length in inches.
R2 = 0.9480315;       % Chamber to converging fillet radius in inches.
b = 45;               % Nozzle converging angle in degrees.
epsilon = 4.9174;     % Nozzle expansion ratio.
Lengthfrac = 80;      % Nozzle length fraction as a percentage.

%RaoNozzleGeom(Dc,Dt,De,Lcyl,R2,b,epsilon,Lengthfrac)

% Constants to set
%function [F1,F2,F3,F4,F5,F6, P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v] = RaoNozzleGeomV2(Dc, Dt, De, Lcyl, R2, b, epsilon, Lengthfrac)
% Derived constants calculations
Rc = Dc/2;            % Determines the radius of the chamber in inches.
Rt = Dt/2;            % Determines the radius of the throat in inches.
Re = De/2;            % Determines the exit radius in inches.
R1 = 1.5*Rt;          % Defines R1 fillet.
Rn = 0.382*Rt;        % Nozzle to throat fillet radius in inches.
granularity = 12;     % Defines number of divisions for each function, graphing fidelity.

% Theta e and theta n determination
Ye100 = @(e) 0.0218*e^2-0.816*e+12.65;% Function for nozzle entrance angle from Rao's research from a 100% nozzle.
Yn100 = @(e) 0.0741*e^2+.0271*e+18.675; % Function for nozzle exit angle from Rao's research from a 100% nozzle.
Ye90 = @(e) 0.0413*e^2+.475*e+20.888;% Function for nozzle entrance angle from Rao's research from a 90% nozzle.
Yn90 = @(e) 0.0405*e^2+.4752*e+18.899; % Function for nozzle exit angle from Rao's research from a 90% nozzle.
Ye80 = @(e) 0.0188*e^2-.9092*e+15.663; % Function for the nozzle entrance angle from Rao's research for an 80% nozzle.
Yn80 = @(e) 0.0413*e^2+.475*e+20.888;  % Function for nozzle exit angle from Rao's research for an 80% nozzle.
Ye70 = @(e) 0.0116*e^2-.837*e+18.589;  % Function for the nozzle entrance angle from Rao's research for an 70% nozzle.
Yn70 = @(e) 0.0288*e^2+.674*e+22.528;  % Function for nozzle exit angle from Rao's research for an 70% nozzle.
Ye60 = @(e) 0.0237*e^2-1.1289*e+22.888;% Function for nozzle entrance angle from Rao's research from a 60% nozzle.
Yn60 = @(e) 0.0222*e^2+.8719*e+24.765; % Function for nozzle exit angle from Rao's research from a 60% nozzle.


if Lengthfrac == 80                    % Checks if an 80 percent nozzle is requested.
thetan = Yn80(epsilon);                % throat to nozzle angle in degrees for an 80% nozzle.
thetae = Ye80(epsilon);                % Nozzle exit angle in degrees for an 80% nozzle.
elseif Lengthfrac == 70
    thetan = Yn70(epsilon);            % throat to nozzle angle in degrees for an 80% nozzle.
    thetae = Ye70(epsilon);            % Nozzle exit angle in degrees for an 80% nozzle.
elseif Lengthfrac == 60
    thetan = Yn60(epsilon);            % throat to nozzle angle in degrees for an 80% nozzle.
    thetae = Ye60(epsilon);            % Nozzle exit angle in degrees for an 80% nozzle.
elseif Lengthfrac == 90
    thetan = Yn90(epsilon);            % throat to nozzle angle in degrees for an 80% nozzle.
    thetae = Ye90(epsilon);            % Nozzle exit angle in degrees for an 80% nozzle.
elseif Lengthfrac == 100
    thetan = Yn100(epsilon);            % throat to nozzle angle in degrees for an 80% nozzle.
    thetae = Ye100(epsilon);            % Nozzle exit angle in degrees for an 80% nozzle.
else
    fprintf("This nozzle percentage is out of range!\nExiting...\n");
    quit cancel;
end



% Plotting
figure(2);
plot(F4x, F4y,'g' ,F4x, -F4y,'g',F3x,F3y,'g' ,F3x, -F3y,'g',F2x,F2y,'g',F2x,-F2y,'g',F1x,F1y,'g',F1x,-F1y,'g',F5x,F5y,'r',F5x,-F5y,'r',F6x,F6y,'r',F6x,-F6y,'r');
title("Nozzle Geometry");
ylabel("Radial position (in)");
xlabel("Longitudinal position (in)");
legend("Chamber","","","","","","","","Nozzle");
axis equal;
%out = [F1,F2,F3,F4,F5,F6, P1, P2, P3, P4, P5, P6];
F1v = [F1x',F1y']; F2v = [F2x',F2y']; F3v = [F3x',F3y']; F4v = [F4x',F4y']; F5v = [F5x',F5y']; F6v = [F6x',F6y'];
%end