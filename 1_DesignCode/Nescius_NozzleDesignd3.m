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
%rhoeth = .789;       % Density of ethanol in kg/L.
%Veth = rhoeth*dens2Svol; % Finds specific volume in ft3/lbf.
Cpeth = 0.520;       % Ethanol specific heat in btu/lbF.
mueth(1) = 0.00000736;  % Viscosity of ethanol in lb/ins.
muweth(1) = .00000736;  
%rhoethI = 62.428*rhoeth/(12^3); % Finds density in lbm/in3.
Kethm = .17;             % Conductivity of ethanol in W/mK
keth = Kethm/.0000133755;           % Ethanol conductivity, BTU-in/hr-ft2-F



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
tcw = .04;          % Inter-channel width in inches.
tc = .04;           % Chamber wall thickness in inches. 
wc = 0.04;           % Sets height of channels.
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
Re(i) = rhox(i)*vx(i)*Dx(i)/12/(mux(i)*12);
if Re>4000
    r(i) = Pr^.35;
else
    r(i) = Pr^.5;
end
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

Aet = .00201; Bet = 1614; Cet = .00618; Det = -1.132E-5;

Aflip = fliplr(A);
Axflip = fliplr(Ax);
Ayflip = fliplr(Ay);
Mxflip = fliplr(Mx);
rflip = fliplr(r);
muxflip = fliplr(mux);
Txflip = fliplr(Tx);

%% Channel solving
fprintf('Staring area solving...\n');

% Ethanol density correlations
% From the paper on ethanol density, the below formula is used.
% dens = P*(mm*T+bm)+mb*T+bb
mm = 9.49593e-7; % Slope of the slope.
bm = -.00034;    % Intercept of the slope.
mb = -.04131;    % Slope of the intercept.
bb = 72.73645;   % Intercept of the intercept.

% Variable initialization. 
thetac = transpose(zeros(Asz,1));
thetacw = transpose(zeros(Asz,1));
thetach = transpose(zeros(Asz,1));
Taw = transpose(zeros(Asz,1));
Tcom = transpose(zeros(Asz,1));
muco = transpose(zeros(Asz,1));
muwc = transpose(zeros(Asz,1));
Tco = transpose(zeros(Asz,1));
Tco(1) = 531.67;                  % Sets initial coolant bulk temp in R.
Ach = transpose(zeros(Asz,1));    % Initializes channel area
Pch = transpose(zeros(Asz,1));
dhc = transpose(zeros(Asz,1));
Preth = transpose(zeros(Asz,1));
vchan = transpose(zeros(Asz,1));
rhoeth = transpose(zeros(Asz,1));
Rechan = transpose(zeros(Asz,1));
Nuchan = transpose(zeros(Asz,1));
hc = transpose(zeros(Asz,1));
for i = 1:1:Asz
% Area solving
Rx = Ayflip(i);
thetac(i) = 360/Nc; 
thetacw(i) = 2*asind(tcw/(4*(Ayflip(i)+tc)));
thetach(i) = thetac(i) - 2*thetacw(i);
Ach(i) = thetach(i)/360*pi*((Rx+tc+wc)^2-(Rx+tc)^2)+wc^2*sind(thetacw(i));
Pch(i) = 4*pi*thetach(i)/360*(2*Ayflip(i)+2*tc+wc)+2*wc; % Finds perimeter of channel segment in inches.
dhc(i) = 4*Pch(i)/Ach(i);
if i < Asz
    dx = abs(Axflip(i) - Axflip(i+1));
    dy = abs(Ayflip(i) - Ayflip(i+1));
    %SAch(i) = 2*pi*Ayflip(i)*sqrt(dx^2+dy^2)*thetach(i)/360;
    SAch(i) = 2*pi*Ayflip(i)*sqrt(dx^2+dy^2)*thetac(i)/360;
else
    SAch(i) = SAch(i-1);
end

% Flow conditions solving
Taw(i) = Tcns*((1+rflip(i)*((gamma-1)/2)*Mxflip(i)^2))/(1+(gamma-1)/2*Mxflip(i)^2);
%Taw(i) = Tcns*.90;
Pch(i) = 420;
sigma = 1/(((1/2*Twgs/Tcns*(1+(gamma-1)/2*Mxflip(i)^2)+1/2)^.68*(1+(gamma-1)/2*Mxflip(i))^.12));
hg = (.026/(Dt^.2)*(muxflip(i)^.2*Cp/(Pr^.6))*(Pcns*g/(cstar*12))^.8*(Dt/R1)^.1)*(At/Aflip(i))^.9*sigma/12;
Tcom(i) = Tco(i)*5/9; Twcms = Twcs*5/9;
muco(i) = Aet*exp(Bet/Tcom(i)+Cet*Tcom(i)+Det*Tcom(i)^2)*0.055997410*10e-3; % Finds ethanol viscosity in lb/ins
muwc = Aet*exp(Bet/Twcms+Cet*Twcms+Det*Twcms^2)*0.055997410e-3; % Finds ethanol viscosity in lb/ins
Preth(i) = muco(i)*Cpeth/keth; % Prandtl number for cooling channels.
%rhoeth(i) = Pch(i)*(mm*Tco(i)+bm)+mb*Tco(i)+bb; % Finds ethanol density in lb/ft3.
rhoeth(i) = 49.3;
vchan(i) = Wdotchan/(rhoeth(i)*Ach(i)*g)*144; % Finds channel velocity in ft/s.
Rechan(i) = rhoeth(i)*vchan(i)*dhc(i);              % Finds the reynolds number within the channels.
Nuchan = .027*Rechan(i)^.8*Preth(i)^.40*(muco(i)/muwc)^.14;         % Finds nusselt number.
hc = keth*Nuchan/dhc(i);                      % Finds hot-gas side heat transfer coefficient.
f1 = hg*(Taw(i)-Twgs) - qs;
f2 = K/tc*(Twgs-Twcs) - qs;
f3 = hc*(Twcs-Tco(i)) - qs;
if i <= 2
[Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs]);
else
[Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs],[Twg(i-1),Twc(i-1),0]);
end
Tco(i+1) = q(i)*SAch(i)*g/12/Wdot/Cpeth + Tco(i);
%Tco(i+1) = Tco(i);
clc;
fprintf('Location: %fin Taw: %fR Twg: %fR Twc: %fR Tco: %fR',Axflip(i),Taw(i),Twg(i),Twc(i),Tco(i));
end

Twg = fliplr(Twg);
Twc = fliplr(Twc);
Taw = fliplr(Taw);
Tco = fliplr(Tco(1:Asz));
q = fliplr(q);

fprintf('\n')

figure(6);
plot(Ax,Ay);
title('Channel area');
xlabel('Longitudinal position (in)');
ylabel('Chamber Area (in2)');
hold on;
yyaxis right;
plot(Ax,fliplr(Ach));
ylabel('Channel Area (in2)');
hold off;

figure(7);
plot(Ax,fliplr(Ach));
title('Channel hydraulic diameter');
xlabel('Longitudinal Position (in)');
ylabel('Channel area (in2)');
hold on;
yyaxis right;
plot(Ax,fliplr(dhc));
ylabel('Hydraulic diamter (in)');
hold off;

figure(8);
plot(Ax,Ay);
title('Channel fluid speed');
xlabel('Longitudinal Position (in)');
ylabel('Radius (in)');
hold on;
yyaxis right;
plot(Ax,fliplr(vchan));
ylabel('Velocity (ft/s)');
hold off;

figure(9);
plot(Ax,Ay);
title('Channel density');
xlabel('Longitudinal Position (in)');
ylabel('Radius (in)');
hold on;
yyaxis right;
plot(Ax,fliplr(rhoeth));
ylabel('Density (lb/ft3)');
hold off;

figure(10);
plot(Ax,fliplr(Preth));
title('Channel flow characteristics');
xlabel('Longitudinal Position (in)');
ylabel('Prandtl number');
hold on;
yyaxis right;
plot(Ax,fliplr(Rechan));
ylabel('Reynolds number');
hold off;

%figure(11);
%plot(Ax,fliplr(Nuchan));
%title('Channel flow characteristics II');
%xlabel('Longitudinal Position (in)');
%ylabel('Nusselt number');
%hold on;
%yyaxis right;
%plot(Ax,fliplr(SAch));
%ylabel('Channel surface area (in2)');
%hold off;

figure(12);
plot(Ax,Tco,Ax,Twc,Ax,Taw,Ax,Twg);
xlabel('Longitudinal position (in)');
ylabel('Temperature (R)');
hold on;
yyaxis right;
plot(Ax,q);
ylabel('Heat transfer (Btu/lbins)');
hold off;
legend ('Coolant bulk','Coolant wall','Adiabatic wall','Gas wall','')