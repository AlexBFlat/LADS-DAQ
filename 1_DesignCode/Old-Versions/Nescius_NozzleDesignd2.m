clear; close all; clc;
%%%% Nescius Injector Design Code
%% To-do updates
% 1. Use ethanol viscosity laws
% 2. Fix areas - negative
% 3. Flip direction
% 4. Average radius of curvature of R1 and R2



%% Conversion factors
gmet = 9.81; % Metric acceleration due to gravity in m/s2.
L2ft3 = 1/28.317; % Conversion from Liters to cubic feet.
lb2N = .224809;   % Conversion from lbf to N.
dens2Svol = L2ft3*gmet*lb2N; % Conversion for metric density to imperial specific volume.

%% Engine constants, imported from RPA analysis
Pcns = 420;          % Chamber stagnation pressure in psi.
Tcns = 5802.507;     % Chamber temperature in R.
OF = 1.596;            % Oxidizer to fuel ratio.
F = 69;              % Thrust in lbs.
rhoeth = .789;       % Density of ethanol in kg/L.
Veth = rhoeth*dens2Svol; % Finds specific volume in ft3/lbf.
Cpeth = 0.520;       % Ethanol specific heat in btu/lbF.
mueth(1) = 0.00000736;  % Viscosity of ethanol in lb/ins.
muweth(1) = .00000736;  
rhoethI = 62.428*rhoeth; % Finds density in lbm/ft3.
keth = 0.0999;           % Ethanol conductivity, BTU-in/hr-ft2-F



% Design Parameters
g = 32.2;            % Acceleration due to gravity in ft/s.
%gamma = [1.1598 1.1598 1.1561 1.1955];     
%gamma = [1.1598 1.1598 1.1598 1.1598];
%M = [22.2429 22.2432 22.4689 23.0151];
%M = [22.2429 22.2429 22.2429 22.2429 ];
M = 22.2429;        % Sets M. Kept constant to maintain isentropic flow.
gamma = 1.1561;     % Sets gamma. Kept constant to maintain isentropic flow.
R = 1544./M;        % Determines gas constant in imperial units.
Mi = .0459;         % Nozzle inlet mach number.
Pe = 14.7;          % Exit pressure in psia.
epsilonc = 22.5;      % Chamber area ratio.
Isp = 252.5994;     % Theoretical Isp in s.
ts = 2.2883e-3;     % Dwell time, sets how long combustion has to complete in the nozzle.
thetarl = 50;         % Sets converging nozzle in degrees.
theta = 90-thetarl;
R2rat = 12;     % Sets nozzle to converging fillet radius in inches.
Lengthfrac = 80;    % Sets length fraction of Rao nozzle. Use 60,70,80,90, or 100.
Ndiv = 100;         % Sets number of divisions for the isentropic solver.
Cp = R/(1-1/gamma); % Specific heat, pressure held constant.
Nc = 20;            % Number of channels.
tc = 0.0393701;           % Chamber and channel thickness in inches.
Twc(1) = 531.671;
hc = 0.15748;           % Sets height of channels.
Kmet = 16.2;       % Thermal conductivity in w/mK
K = Kmet/74763.8199;% Finds thermal conductivity in Btu/F/in/s.

%% Solving
[stat, Wdot, epsilon] = stationsolvCONGAM(gamma,R,Pcns,Tcns,Pe,Mi,F,g,epsilonc); % Solves for flow conditions at various stations within the nozzle.
Pinj = str2double(stat(2,2)); Tinj = str2double(stat(2,3)); Vinj = str2double(stat(2,4)); vinj = str2double(stat(2,5)); Ac = str2double(stat(2,6));
Pi = str2double(stat(3,2)); Ti = str2double(stat(3,3)); Vi = str2double(stat(3,4)); vi = str2double(stat(3,5));
Pt = str2double(stat(4,2)); Tt = str2double(stat(4,3)); Vt = str2double(stat(4,4)); vt = str2double(stat(4,5)); At = str2double(stat(4,6));
Pe = str2double(stat(5,2)); Te = str2double(stat(5,3)); Ve = str2double(stat(5,4)); ve = str2double(stat(5,5)); Ae = str2double(stat(5,6));
Wdotchan = Wdot/Nc/(1+OF); % Finds individual channel weight flowrate.
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
[F1,F2,F3,F4,F5,F6,P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v,R1] = RaoNozzleGeom(Dc,Dt,De,Lcyl,R2rat,theta,epsilon,Lengthfrac); % Finds nozzle geometry functions and values and plots them.
z = 0; % Storage variable.
%% Isentropic flow solving
% Nozzle area solving
Lco = P6(1) + abs(P0(1)); % Finds the total chamber length in inches.
Leo = P6(1);              % Finds the total nozzle length in inches.
L = Lco + Leo;            % Finds total length of chamber in inches.
%% F1 area solving
% From P0 to P1
A1x = double(linspace(P0(1),P1(1),Ndiv));         % Finds area X values for F1.
A1 = double(pi.*(linspace(F1(1),F1(1),Ndiv)).^2); % Finds area Y values for F1.
[z,A1sz] = size(A1);                              % Finds size of area array.
%% F2 area solving
% From P1 to P2
A2x = double(linspace(P1(1),P2(1),Ndiv)); % Finds area X values for F2.
A2 = double(pi.*(F2(A2x)).^2);            % Finds area Y values for F2.
[z,A2sz] = size(A2);                      % Finds size of area array.
%% F3 area solving
% From P2 to P3
A3x = double(linspace(P2(1),P3(1),Ndiv)); % Finds X area values for F3.
A3 = double(pi.*(F3(A3x)).^2);            % Finds Y area values for F3.
[z,A3sz] = size(A3);                      % Finds size of area array.
%% F4 area solving
% From P3 to P4
A4x = double(linspace(P3(1),P4(1),Ndiv)); % Finds X area values for F4.
A4 = double(pi.*(F4(A4x)).^2);            % Finds Y area values for F4.
[z,A4sz] = size(A4);                      % Finds size of area array.

%% F5 area solving
% From P4 to P5
A5x = double(linspace(P4(1),P5(1),Ndiv)); % Finds X area values for F5.
A5 = double(pi.*(F5(A5x)).^2);            % Finds Y area values for F5.
[z,A5sz] = size(A5);                      % Finds size of area array.

%% F6 area solving
% From P5 to P6
A6x = double(linspace(P5(1),P6(1),Ndiv)); % Finds X area values for F6.
A6 = double(pi.*(F6(A6x)).^2);            % Finds Y area values for F6.
[z,A6sz] = size(A6);                      % Finds size of area array.

tol = 0.01;
%% Area function stitching
A = [A1, A2(2:A2sz), A3(2:A3sz), A4(2:A4sz), A5(2:A5sz), A6(2:A6sz)];        % Stiches the area values into a continues array of area values.
[z, Asz] = size(A);                                                          % Finds size of Area array.
Ax = [A1x, A2x(2:A2sz), A3x(2:A3sz), A4x(2:A4sz), A5x(2:A5sz), A6x(2:A6sz)]; % Sets x values for area array.

AxAt = zeros(1,Asz);        % Allocates size of AxAt, area ratio.
syms Mxs;                   % Creates symbolic Mx for solving for mach number.
syms vxs;                   % Creates symbolic vx for solving for static pressure.
syms Pxs;
syms qs; syms Twgs; syms Twcs;
Mx = zeros(1,Asz);          % Allocates space for M(x). 
Px = zeros(1,Asz);          % Allocates space for P(x).
Tx = zeros(1,Asz);          % Allocates space for T(x).
vx = zeros(1,Asz);          % Allocates space for v(x).
ax = zeros(1,Asz);          % Allocates space for V(x).
vx = zeros(1,Asz);          % Allocates space for v(x).
tolerance = 1e-6;
%% Isentropic flow solving
% Iterates through all nozzle points.
it = find(Ax==0);
Pr = 4*gamma/(9*gamma-5);
cstar = Pcns*At*g/Wdot;
Ay = abs(sqrt(A./pi)); % Finds the y values of the chamber in inches.
%Tco = linspace(531.67,700,Asz); % Initial coolant temp in R.
Tco(1) = 531.67;
for i = 1:1:Asz
AxAt(i) = A(i)/At; % Finds area ratio at each point.
funcM = ((gamma+1)/2)^(-(gamma+1)/2/(gamma-1))*(1+(gamma-1)/2*Mxs^2)^((gamma+1)/2/(gamma-1))/Mxs - AxAt(i);
funcP = ((2/(gamma+1))^(1/(gamma-1))*(Pcns/Pxs)^(1/gamma))/sqrt((gamma+1)/(gamma-1)*(1-(Pxs/Pcns)^((gamma-1)/gamma))) - AxAt(i);

if i <= it
    Minit = .1;
    Pinit = Pcns;
else
    Minit = 1.1;
    Pinit = Pe;
end
if i == it
Mx(i) = 1;
Px(i) = Pt;
else
Mx(i) = real(vpasolve(funcM,Mxs,Minit));
end
Px(i) = Pcns*(1+(gamma-1)/2*Mx(i)^2)^(-(gamma/(gamma-1)));
Tx(i) = Tcns*(Px(i)/Pcns)^((gamma-1)/gamma);
vx(i) = sqrt(2*g*gamma/(gamma-1)*R*Tcns*(1-(Px(i)/Pcns)^((gamma-1)/gamma)));
Vx(i) = R*Tx(i)/144/Px(i);
Dx(i) = abs(sqrt(4*A(i)/pi));
rhox(i) = g/Vx(i);
% Heat transfer
mux(i) = (46.6e-10)*M^.5*Tx(i)^.6;
Re(i) = rhox(i)*vx(i)*Dx(i)/mux(i);
if Re>4000
    r(i) = Pr^.35;
else
    r(i) = Pr^.5;
end
Taw(i) = Tcns*((1+r(i)*((gamma-1)/2)*Mx(i)^2))/(1+(gamma-1)/2*Mx(i)^2);


%sigma(i) = 1/((1/2*Twg(i)/Tcns*(1+(gamma-1)/2*Mx(i)^2))^.68*(1+(gamma-1)/2*Mx(i))^.12);
%hg(i) = (.026/(Dt^.2)*(mux(i)^.2*Cp/(Pr^.6))*(Pcns*g/(cstar))^.8*(Dt/R)^.1)*(At/A(i))^.9*sigma(i)/12;
%% Channel initial solving
%mueth(i) = mueth(1)*(Tco(i)/Tco(1))^1.5*((Tco(1)+198.72)/(Tco(i)+198.72)); % FIX LATER FOR GAS NOT LIQUID
%muweth(i) = muweth(1)*(Twc(i)/Twc(1))^1.5*((Twc(1)+198.72)/(Twc(i)+198.72)); % FIX LATER FOR GAS NOT LIQUID
%Preth(i) = mueth(i)*Cpeth/keth; % Prandtl number for cooling channels.
%thetacd(i) = 360/Nc - 2*asind(tc/(2*Ay(i))); % Finds the angle that defines the portion taken up by each channel at each point in degrees.
%thetacd(i) = 360/Nc - asind(tc/(Ay(i)));
%Ach(i) = pi*thetacd(i)/360*(2*Ay(i)*hc+hc^2); % Finds the area of each channel.
%vchan(i) = 144*Wdotchan*Veth/Ach(i);              % Finds the velocity, in ft/s, of the flow at each point in the cooling channels.
%Pch(i) = 2*tc+2*pi*thetacd(i)/360*(2*Ay(i)+tc); % Finds channel perimeter in inches at each point.
%dhc(i) = 4*Pch(i)/Ach(i);                         % Finds hydraulic diameter in inches at each point.
%dhc(i) = hc;
%Rech(i) = rhoethI*vchan(i)*dhc(i)/mueth(i);        % Finds reynolds number.
%Gc(i) = Wdotchan/Ach(i);                        % Finds weight flowrate per unit area of a channel.

%% Function creation

%hcf = .029*Cpeth*mueth(i)^.2/(Preth(i)^(2/3))*(Gc(i)^.8/(dhc(i)^.2))*(Tco(i)/Twcs);
%Rechan(i) = rhoethI*vchan(i)*dhc(i)/mueth(i);
%Nuc(i) = .027*Rechan^.8*Preth(i)^.4*(mueth(i)/muweth(i))
%hcf(i) = Nuc(i)*keth/dhc(i);
%sigmaf = 1/((1/2*(Twgs/Tcns*(1+(gamma-1)/2*Mx(i)))+1/2)^.68*(1+(gamma-1)/2*Mx(i)^2)^.12);
%qf1 = hcf*(Twcs - Tco(i)) - qs;
%hgf = (0.026/(Dt^.2)*((mueth(i)^.2*Cpeth/(Preth(i)^.6)))*((Pcns*g)/cstar)^.8*(Dt/R1)^.3)*(At/A(i))^.9*sigmaf;
%qf2 = hgf*(Taw(i) - Twgs) - qs;
%qf3 = K/tc*(Twgs-Twcs) - qs;
%if i <= 2
%    [Twg(i), Twc(i), q(i)] = vpasolve([qf1,qf2,qf3],[Twgs,Twcs,qs],[Taw(1),Tco(1),0]);
%end
%if i <= it && i > 2
%    [Twg(i), Twc(i), q(i)] = vpasolve([qf1,qf2,qf3],[Twgs,Twcs,qs],[Twg(i-1),Twc(i-1),0]);
%end
%if i > it
%    [Twg(i), Twc(i), q(i)] = vpasolve([qf1,qf2,qf3],[Twgs,Twcs,qs],[Twg(i-1),Twc(i-1),q(i-1)]);
%end
%if i < Asz-1
%dx(i) = abs(Ax(i)-Ax(i+1));
%dy(i) = abs(Ay(i)-Ay(i+1));
%SAch(i) = pi*sqrt(dy(i)^2+dx(i)^2)*(Ay(i)+Ay(i+1))*thetacd(i)/360;
%else
%    dx(i) = dx(i-1);
%    dy(i) = dy(i-1);
%    SAch(i) = SAch(i-1);
%end
%Tco(i+1) = q(i)*SAch(i)*g/Wdot/Cpeth + Tco(i);
%Tco(i+1) = Tco(1);
%Tco(i+1) = Tco(i) + 1;
%clc;
%fprintf('Iteration: %i Heat transfer: %fBTU/in2s Coolant bulk temp: %fR gas-wall temp: %fR\nCoolant wall temp: %fR Gas temp: %fR Area: %fin2',i,q(i),Tco(i),Twg(i),Twc(i),Tx(i),SAch(i));
end

figure(2);
plot(Ax,Mx);
title('Mach and area ratios');
xlabel('Lateral position (in)');
ylabel('Mach number');
hold on;
yyaxis right;
plot(Ax,vx);
ylabel('Velocity (ft/s)');
hold off;

figure(3);
plot(Ax,Px);
title('Pressure and Temperature');
xlabel('Lateral position (in)');
ylabel('Pressure (psia)');
hold on;
yyaxis right;
plot(Ax,Tx);
ylabel('Temperature (R)');
plot(Ax,Tx);
hold off;

figure(4);
plot(Ax,Vx);
title('Specific volume');
xlabel('Lateral position (in)');
ylabel('Specific volume (ft3/lb)');

figure(5);
plot(F1v(:,1),F1v(:,2),'r',F1v(:,1),-F1v(:,2),'r',F2v(:,1),F2v(:,2),'r',F2v(:,1),-F2v(:,2),'r',F3v(:,1),F3v(:,2),'r',F3v(:,1),-F3v(:,2),'r',F4v(:,1),F4v(:,2),'r',F4v(:,1),-F4v(:,2),'r',F5v(:,1),F5v(:,2),'r',F5v(:,1),-F5v(:,2),'r',F6v(:,1),F6v(:,2),'r',F6v(:,1),-F6v(:,2),'r');
ylabel('Radial position (in)');
xlabel('Longitudinal Position (in)');


