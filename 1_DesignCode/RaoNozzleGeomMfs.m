%clear; close all; clc;
%Dc = 1.6532;          % Defines chamber diameter in inches.
%Dt = 0.3793;          % Chamber throat diameter in inches.
%De = 0.8410;          % Defines chamber exit diameter in inches.
%Lcyl = 2.14789559200; % Defines chamber cylinder length in inches.
%R2 = 0.9480315;       % Chamber to converging fillet radius in inches.
%b = 45;               % Nozzle converging angle in degrees.
%epsilon = 4.9174;     % Nozzle expansion ratio.
%Lengthfrac = 80;      % Nozzle length fraction as a percentage.

%RaoNozzleGeom(Dc,Dt,De,Lcyl,R2,b,epsilon,Lengthfrac)

% Constants to set
function [F1,F2,F3,F4,F5,F6, P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v,R1] = RaoNozzleGeomMfs(Dc, Dt, De, Lcyl, R2rat, b, epsilon, Lengthfrac)
options = optimset('Display','off');
% Conversion factors
lb2N = 4.448;  % Conversion factor lbf to N.
Psi2Pa = 6895; % Conversion factor psia to Pa.
in2m = 39.37;  % Conversion factor in to m.
R2K = 5/9;     % Conversion factor R to K.
% Derived constants calculations
Rc = Dc/2;            % Determines the radius of the chamber in inches.
Rt = Dt/2;            % Determines the radius of the throat in inches.
Re = De/2;            % Determines the exit radius in inches.
R1 = 1.5*Rt;          % Defines R1 fillet.
Rn = 0.382*Rt;        % Nozzle to throat fillet radius in inches.
R2 = Rt*R2rat;   
Lcyl = Lcyl;
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


% Function definitions
F4 = @(x) R1+Rt-sqrt(R1.^2-x.^2); % Defines function four, the join between the converging section and the throat.

% Joining points definitions
% P3
P3xf = @(x3s) -tand(b) + x3s/sqrt(R1^2-x3s^2); % Creates a function to find the x coordinate of P3.
P3x = -fsolve(P3xf,0,options);              % Sounds for the x coordinate of P3.
P3y = F4(P3x);                         % Finds the y coordinate of P3.
P3 = [P3x, P3y];                       % Defines point 3.
% P2
P2y =( Rc - (R2*sind(b))/(tand((180-b)/2))); % Finds P2 y coord.
P2x = -((P2y-P3y)/tand(b)-P3x);
P2 = [P2x P2y];
% P1
P1x = P2x - R2*sind(b);
P1y = Rc;
P1 = [P1x P1y];
% P6
P6y = Re;
%P6x = Re/tand(thetae);

Lnc = (sqrt(epsilon)-1)*Rt/tand(15);


% F3 plotting preparation
m3 = (P2y-P3y)/(P2x-P3x);
b3 = P3y - m3*P3x;
F3x = linspace(P2x,P3x,granularity);
F3 = @(x) m3.*x + b3;
F3y = F3(F3x); 

% F2 plotting preparation
F2 = @(x) Rc - R2 + sqrt(R2^2-(x-P1x).^2);
F2x = linspace(P2x,P1x,granularity);
F2y = F2(F2x);

% F1 plotting operation
Lc = Lcyl + abs(P1x);
P0(1) = -Lc;
P0(2) = Rc;
F1x = linspace(-Lc,P1x,granularity);
F1y = linspace(Rc,Rc,granularity);
F1 = @(x) Rc;

% F4 plotting preparation
F4x = linspace(P3x,0,granularity); % Defines all x points for function 4.
F4y = F4(F4x);            % Finds y values for function 4.

% F5 plotting preparations
F5 = @(x) Rn + Rt - sqrt(Rn^2-x.^2);
F5f = @(x5) -x5/sqrt(Rn^2-x5^2)-tand(thetan);
P5x = abs(fsolve(F5f,0,options));
P5y = F5(P5x);
F5x = linspace(0,P5x,granularity);
F5y = F5(F5x);
P5 = [P5x P5y];

% F6 Plotting preparations
syms a; syms P; syms k; syms h;
F6f1 = sqrt((P5x-h)/a) + k - P5y;
F6f2 = sqrt((P-h)/a) + k - Re;
F6f3 = 1/(2*a*sqrt((P5x-h)/a)) - tand(thetan);
F6F4 = 1/(2*a*sqrt((P-h)/a)) - tand(thetae);
F6sol = solve(F6f1,F6f2,F6f3,F6F4,a,P,k,h);
P6x = F6sol.P;
a6 = F6sol.a;
k6 = F6sol.k;
h6 = F6sol.h;
F6 = @(x) sqrt((x-h6)./a6)+k6;
F6x = linspace(P5x,P6x,granularity);
F6y = F6(F6x);
Lt = abs(P1x) + P6x + Lcyl;
P4 = [0, Rt];
P6 = [P6x P6y];

% Plotting
%figure(2);
%plot(F4x, F4y,'g' ,F4x, -F4y,'g',F3x,F3y,'g' ,F3x, -F3y,'g',F2x,F2y,'g',F2x,-F2y,'g',F1x,F1y,'g',F1x,-F1y,'g',F5x,F5y,'r',F5x,-F5y,'r',F6x,F6y,'r',F6x,-F6y,'r');
%title("Nozzle Geometry");
%ylabel("Radial position (in)");
%xlabel("Longitudinal position (in)");
%legend("Chamber","","","","","","","","Nozzle");
%axis equal;
%out = [F1,F2,F3,F4,F5,F6, P1, P2, P3, P4, P5, P6];
F1v = [F1x',F1y']; F2v = [F2x',F2y']; F3v = [F3x',F3y']; F4v = [F4x',F4y']; F5v = [F5x',F5y']; F6v = [F6x',F6y'];
end