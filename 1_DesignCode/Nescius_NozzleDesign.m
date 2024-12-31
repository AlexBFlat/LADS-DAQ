clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
Pcns = 420;          % Chamber stagnation pressure in psi.
Tcns = 5802.507;     % Chamber temperature in R.
OF = 1.5;            % Oxidizer to fuel ratio.
%F = 70.02;              % Thrust in lbs.
F = 69;

% Design Parameters
g = 32.2;            % Acceleration due to gravity in ft/s.
gamma = [1.1598 1.1598 1.1561 1.1955];     
%gamma = [1.1598 1.1598 1.1598 1.1598];
M = [22.2429 22.2432 22.4689 23.0151];
%M = [22.2429 22.2429 22.2429 22.2429 ];
R = 1544./M;        % Determines gas constant in imperial units.
Mi = .0459;         % Nozzle inlet mach number.
Pe = 14.7;          % Exit pressure in psia.
epsilonc = 20;      % Chamber area ratio.
Isp = 252.5994;     % Theoretical Isp in s.
ts = 2.2883e-3;     % Dwell time, sets how long combustion has to complete in the nozzle.
thetarl = 50;         % Sets converging nozz le in degrees.
theta = 90-thetarl;
R2 = 0.9480315;     % Sets nozzle to converging fillet radius in inches.
Lengthfrac = 80;    % Sets length fraction of Rao nozzle. Use 60,70,80,90, or 100.
Ndiv = 100;         % Sets number of divisions for the isentropic solver.

%% Solving
[stat, Wdot, epsilon] = stationsolve(gamma,R,Pcns,Tcns,Pe,Mi,F,Isp,g,epsilonc); % Solves for flow conditions at various stations within the nozzle.
Pinj = str2double(stat(2,2)); Tinj = str2double(stat(2,3)); Vinj = str2double(stat(2,4)); vinj = str2double(stat(2,5)); Ac = str2double(stat(2,6));
Pi = str2double(stat(3,2)); Ti = str2double(stat(3,3)); Vi = str2double(stat(3,4)); vi = str2double(stat(3,5));
Pt = str2double(stat(4,2)); Tt = str2double(stat(4,3)); Vt = str2double(stat(4,4)); vt = str2double(stat(4,5)); At = str2double(stat(4,6));
Pe = str2double(stat(5,2)); Te = str2double(stat(5,3)); Ve = str2double(stat(5,4)); ve = str2double(stat(5,5)); Ae = str2double(stat(5,6));

% Chamber sizing
Vavg = median([Vinj Vi]); % Finds chamber average specific volume in ft3/lb.
Vc = Wdot*Vavg*ts; % Finds chamber volume in square feet.
Vcin = Vc*12^3;    % Finds chamber volume in square inches.
Lstar = Vcin/At;   % Finds Lstar in inches.
syms Lc;           % Sets the chamber length as a symbolic.
func = At*(Lc*epsilonc+1/3*sqrt(At/pi)*cotd(theta)*(epsilonc^(1/3)-1))-Vcin; % Solves for chamber barrel length in inches.
Lc = vpasolve(func);% Finds chamber length in inches.
Lcyl = Lc;          % Sets Lcyl as Lc.
epsiloncG = linspace(2, 20); % Creates an epsilon array for graphing of epsilon values.
Lcvals = (Vcin./At - 1/3.*sqrt(At./pi).*cotd(theta).*(epsiloncG.^(1/3)-1))./epsiloncG; % Sets chamber length vals for graphing.
Dc = 2*sqrt(Ac/pi); % Finds chamber diameter in inches.
Dt = 2*sqrt(At/pi); % Finds throat diameter in inches.
De = 2*sqrt(Ae/pi); % Finds exit diameter in inches.

% Epsilon versus length plotting
figure(1);                                         % Creates figure.
plot(epsiloncG, Lcvals);                           % Plots epsilon versus length.
title('Chamber length versus chamber area ratio'); % Graph title
xlabel('Chamber area ratio');                      % Sets axis labels.
ylabel('Chamber length (in)');                     %
% Chamber plotting
[F1,F2,F3,F4,F5,F6,P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v] = RaoNozzleGeom(Dc,Dt,De,Lcyl,R2,theta,epsilon,Lengthfrac); % Finds nozzle geometry functions and values and plots them.
z = 0; % Storage variable.
%% Isentropic flow solving
% Nozzle area solving
Lco = P6(1) + abs(P0(1)); % Finds the total chamber length in inches.
Leo = P6(1);              % Finds the total nozzle length in inches.
L = Lco + Leo;            % Finds total length of chamber in inches.
%% F1 area solving
% From P0 to P1
A1x = double(linspace(P0(1),P1(1),Ndiv));
A1 = double(pi.*(linspace(F1(1),F1(1),Ndiv)).^2);
[z,A1sz] = size(A1);
%% F2 area solving
% From P1 to P2
A2x = double(linspace(P1(1),P2(1),Ndiv));
A2 = double(pi.*(F2(A2x)).^2);
[z,A2sz] = size(A2);
%% F3 area solving
% From P2 to P3
A3x = double(linspace(P2(1),P3(1),Ndiv));
A3 = double(pi.*(F3(A3x)).^2);
[z,A3sz] = size(A3);
%% F4 area solving
% From P3 to P4
A4x = double(linspace(P3(1),P4(1),Ndiv));
A4 = double(pi.*(F4(A4x)).^2);
[z,A4sz] = size(A4);

%% F5 area solving
% From P4 to P5
A5x = double(linspace(P4(1),P5(1),Ndiv));
A5 = double(pi.*(F5(A5x)).^2);
[z,A5sz] = size(A5);

%% F6 area solving
% From P5 to P6
A6x = double(linspace(P5(1),P6(1),Ndiv));
A6 = double(pi.*(F6(A6x)).^2);
[z,A6sz] = size(A6);

tol = 1e-6;
%% Area function stitching
A = [A1, A2(2:A2sz), A3(2:A3sz), A4(2:A4sz), A5(2:A5sz), A6(2:A6sz)];
[z, Asz] = size(A);
Ax = [A1x, A2x(2:A2sz), A3x(2:A3sz), A4x(2:A4sz), A5x(2:A5sz), A6x(2:A6sz)];
R1 = linspace(R(1),R(2),Ndiv);
R2 = linspace(R(2),R(3),Ndiv*3-2);
R3 = linspace(R(3),R(4),Ndiv*2-1);
Rs = [R1,R2(2:Ndiv*3-2),R3(2:Ndiv*2-1)];
ga1 = linspace(gamma(1),gamma(2),Ndiv);
R1 = linspace(R(1),R(2),Ndiv);
ga2 = linspace(gamma(2),gamma(3),Ndiv*3-2);
R2 = linspace(R(2),R(3),Ndiv*3-2);
ga3 = linspace(gamma(3),gamma(4),Ndiv*2-1);
R3 = linspace(R(3),R(4),Ndiv*2-1);
gammas = [ga1,ga2(2:Ndiv*3-2),ga3(2:Ndiv*2-1)];
Rs = [R1,R2(2:Ndiv*3-2),R3(2:Ndiv*2-1)];
Arats = A./At;
% Isentropic solving
strtsol = 1;
P = zeros(1,Asz);
%T = zeros(1,Asz);
%a = zeros(1,Asz);
%v = zeros(1,Asz);
%V = zeros(1,Asz);
Taw = Tcns*0.90;
cstar = Pcns*At*g/Wdot;
for i = 1:1:Asz
% Solving for mach number
gai = gammas(i);
syms Msym;
Func = ((gai+1)/2)^(-((gai+1)/(2*(gai-1))))*(1+(gai-1)/2*Msym^2)^((gai+1)/(2*(gai-1)))/Msym - Arats(i);
%Func = ((gai+1)/2)^(-((gai+1)/2*(gai-1)))*(1+(gai-1)/2*Msym^2)^((gai+1)/(2*(gai-1)))/Msym - A(i)/At;
if i >= 2
strtsol = M(i-1);
Mf = vpasolve(Func,Msym,strtsol);
else
Mf = 0.001;
end

if (Arats(i)-1)<tol
    M(i) = 1;
else
M(i) = Mf;
end
P(i) = Pcns*(1+(gai-1)/2*M(i)^2)^(-gai/(gai-1));
T(i) = Tcns*(1+(gai-1)/2*M(i)^2)^(-1);
V(i) = Rs(i)*T(i)/144/P(i);
v(i) = 144*V(i)*Wdot/A(i);
% Finding locations
if (A(i)-At)<tol
    it = i;
    xt = Ax(i);
end
if abs(A(i)-Ac)<.01
    ic = i;
    xc = Ax(i);
end
if (A(i)-Ae)<tol
    ie = i;
    xe = Ax(i);
end
%Cp(i) = gai*Rs(i)/(gai-1);
%rhoprm(i) = (12)^3/V(i); % Finds density in terms of cubic inches.
%hgest(i) = (rhoprm(i)*v(i)*12)^(.8); % Gets estimaed gas-side heat transfer coefficient in Btu/in2-s-deg
%Pr(i) = 4*gai/(9*gai-5); % Approximation of prandtl number.
%sigma(i) = 1/(1/2*T(i)/Tcns*(1+(gai-1)/2*M(i)^2)^.68*(1+(gai-1)/2*M(i)^2)^.12);
%mu(i) = (46.6e-10)*M(i)^(0.5)*T(i)^(0.6); % Finds viscosity value.
%Hgbartz(i) = ((0.026/Dt^0.2)*(mu(i)^0.2*g/cstar)^0.8*(Dt/Rs(i))^0.1)*(At/A(i))^0.9*sigma(i);
%q(i) = Hgbartz(i)*(Taw-T(i));
end

Ffunc = @(M) ((gai+1)/2)^(-((gai+1)/(2*(gai-1))))*(1+(gai-1)/2*M^2)^((gai+1)/(2*(gai-1)))/M;
%% Final plotting
hFig2 = figure(2);
set(hFig2, 'Position', [960 140 900 400]);
plot(F1v(:,1),F1v(:,2),'r',F1v(:,1),-F1v(:,2),'r',F2v(:,1),F2v(:,2),'r',F2v(:,1),-F2v(:,2),'r',F3v(:,1),F3v(:,2),'r',F3v(:,1),-F3v(:,2),'r',F4v(:,1),F4v(:,2),'r',F4v(:,1),-F4v(:,2),'r',F5v(:,1),F5v(:,2),'r',F5v(:,1),-F5v(:,2),'r',F6v(:,1),F6v(:,2),'r',F6v(:,1),-F6v(:,2),'r');
ylabel('Radial position (in)');
xlabel('Longitudinal Position (in)');
hold on;
yyaxis right;
ylabel('Mach number');
plot(Ax,A);
hold off;
legend("Chamber","","","","","","","","Nozzle","","","","Chamber area");
hFig3 = figure(3);
set(hFig3, 'Position', [960 140 900 200]);
plot(Ax,P);
ylabel('Pressure (psia)');
xlabel('Longitudinal Position (in)');
hold on;
yyaxis right;
plot(Ax,T);
ylabel('Temperature (R)');
hold off;


%% Accuracy checks
% Chamber conditions
Pcer = abs((Pcns - P(ic))/Pcns*100);
Tcer = abs((Tcns - T(ic))/Tcns*100);
Vcer = abs((Vinj - V(ic))/Vinj*100);
% Throat conditions
Pter = abs((Pt - P(it))/Pt*100);
Tter = abs((Tt - T(it))/Tt*100);
Vter = abs((Vt - V(it))/Vt*100);
% Exit conditions
Peer = abs((Pe - P(ie))/Pe*100);
Teer = abs((Te - T(ie))/Te*100);
Veer = abs((Ve - V(ie))/Ve*100);
Isprl = (v(i)/g);
Isper = abs((Isprl-Isp)/Isp*100);
Frl = Wdot*v(i)/g+A(i)*(P(i)-Pe);
Fer = abs((Frl-F)/F*100);

% Result printing
fprintf('Solver Errors\n');
fprintf('Pc: %f%% Pt: %f%% Pe: %f%%\n',Pcer,Pter,Peer);
fprintf('Tc: %f%% Tt: %f%% Te: %f%%\n',Tcer,Tter,Teer);
fprintf('Vc: %f%% Vt: %f%% Ve: %f%%\n',Vcer,Vter,Veer);
fprintf('F: %f%% Isp: %f%%\n',Fer,Isper);
fprintf('Frl: %.2flbf Isprl: %f.2s\n',Frl,Isprl);

%hFig4 = figure(4);
%set(hFig4, 'Position', [960 140 900 200]);
%plot(Ax,V);
%ylabel('Specific Volume (ft3/lbm)');
%xlabel('Longitudinal Position (in)');
%hold on;
%yyaxis right;
%plot(Ax,v);
%ylabel('velocity (ft/s)');
%hold off;
%figure(5);
%plot(Ax,hgest);
%xlabel('Longitudinal Position (in)');
%ylabel('hg estimated');
%hold on;
%yyaxis('Right');
%plot(Ax,q);
%ylabel('Heat transfer');
%hold off;
