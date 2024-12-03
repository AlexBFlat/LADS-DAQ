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
Rn = 0.382*Rt; % Nozzle to throat fillet radius in inches.
granularity = 12; % Defines number of divisions for each function.
epsilon = 4.9174;
Ye = @(e) 0.0188*e^2-.9092*e+15.663;
Yn = @(e) 0.0413*e^2+.475*e+20.888;
thetan = Yn(epsilon); % throat to nozzle angle in degrees for an 80% nozzle.
thetae = Ye(epsilon);  % Nozzle exit angle in degrees for an 80% nozzle.

% Function definitions
f4 = @(x) R1+Rt-sqrt(R1.^2-x.^2); % Defines function four, the join between the converging section and the throat.

% Joining points definitions
% P3
syms x3s;
P3xf = -tand(b) + x3s/sqrt(R1^2-x3s^2); % Creates a function to find the x coordinate of P3.
P3x = -vpasolve(P3xf,x3s);              % Sounds for the x coordinate of P3.
P3y = f4(P3x);                         % Finds the y coordinate of P3.
P3 = [P3x, P3y];                       % Defines point 3.
% P2
P2y =( Rc - (R2*sind(b))/(tand((180-b)/2))); % Finds P2 y coord.
P2x = -((P2y-P3y)/tand(b)-P3x);
% P1
P1x = P2x - R2*sind(b);
P1y = Rc;
% P6
P6y = Re;
P6x = Re/tand(thetae);

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
F1x = linspace(-Lc,P1x,granularity);
F1y = linspace(Rc,Rc,granularity);
F1 = @(x) Rc;

% F4 plotting preparation
F4x = linspace(P3x,0,granularity); % Defines all x points for function 4.
F4y = f4(F4x);            % Finds y values for function 4.

% F5 plotting preparations
F5 = @(x) Rn + Rt - sqrt(Rn^2-x.^2);
syms x5;
F5f = -x5/sqrt(Rn^2-x5^2)-tand(thetan);
P5x = abs(vpasolve(F5f,x5));
F5x = linspace(0,P5x,granularity);
F5y = F5(F5x);

% F6 Plotting preparations
syms a; syms P; syms k;
F6f1 = tand(thetan) - 1/(2*a*sqrt(P5x/a));
a6 = vpasolve(F6f1,a);
F6f2 = tand(thetae) - 1/(2*a6*sqrt(P/a6));
dP6x = vpasolve(F6f2,P);
Ln8 = .8*Lnc+P5x;
P6x = Ln8;
P6y = Re;

% Plotting
figure(1);
plot(F4x, F4y,'g' ,F4x, -F4y,'g',F3x,F3y,'g' ,F3x, -F3y,'g',F2x,F2y,'g',F2x,-F2y,'g',F1x,F1y,'g',F1x,-F1y,'g',F5x,F5y,'g',F5x,-F5y,'g');