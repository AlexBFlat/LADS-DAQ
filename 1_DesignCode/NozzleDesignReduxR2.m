%  ||//////////////////////////////
%% || Initializations and setup //
%  ||////////////////////////////
%  Design input values

clear; close all; clc;
%% Introduction
fprintf(['/////////////////////////////////////\n' ...
         'Parametric Nozzle Design Program ///\n' ...
         'Version: 0.01 Updated: 1/4/2025 ///\n' ...
         '//////////////////////////////////\n'])


%  ||/////////////////
%% || Input values //
%  ||///////////////
%  Design input values
% Engine performance
F = 69;          % Thrust in lb.
Isp = 261;  % Isp in seconds.
of = 1.596;      % Oxidizer to fuel ratio.
epsilonc = 22.5;
%epsilonc = 22.5; % Chamber area ratio.
thetacon = 50;   % converging section angle in degrees.
% Engine pressures
Pc = 420;        % Chamber pressure in psia.
Pe = 14.7;       % Exit pressure in psia.
% Engine temperatures
Tco(1) = 273.15; % Initial coolant bulk temperature in K.
Tcns = 5802.507; % Chamber temperature in R.
% Engine mach numbers
Mi = .0459;      % Sets nozzle inlet mach number.
% Geometric constants
R2rat = 1.5;     % Ratio of R2 to Rt.
Lengthfrac = 80; % Rao nozzle length fraction in percent.
Ndiv = 120;
Nc = 20;         % Number of channels
tc = 1e-3;       % Thickness of chamber wall in meters.
tcw = 1e-3;      % Thickness of channel wall in meters.
wc = 1e-3;       % Channel heigh in meters.
% Environmental constants
g = 9.81;        % Acceleration due to gravity in m/s2.
gamma = 1.1598;  % Gamma of combustion gasses.
M = 22.2429;     % Molar mass of combustion gasses in kmol.
Ro = 8314.36;    % Universal gas constant in J/kmol/K
R = Ro/M;        % Gas constant in J/kgK.
Lstar = 63.27;   % Sets L star in inches, the characteristic nozzle length for ethanol.
Keth = .17;      % Thermal conductivity of ethanol in W/mK.
Kss = 15;        % Thermal conductivity of stainless steel in W/mk.

% Value printing
fprintf(['|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n' ...
         '/////////////////////////////// Design set points ///////////////////////////////\n' ...
         'Thrust: %flb Isp: %fs O/F: %f Contraction ratio: %f\n'],F,Isp,of,epsilonc);

%  ||/////////////////////////////
%% || Initial unit conversions //
%  ||///////////////////////////
% Conversion factors
lb2N = 4.448;  % Conversion factor lbf to N.
Psi2Pa = 6895; % Conversion factor psia to Pa.
in2m = 39.37;  % Conversion factor in to m.
R2K = 5/9;     % Conversion factor R to K.
% Conversions
F = lb2N*F;         % Converts thrust to N.
Pcns = Psi2Pa*Pc;   % Converts chamber pressure to Pa.
Pe = Psi2Pa*Pe;     % Converts exit pressure to Pa.
Tcns = Tcns*R2K;    % Converts chamber temperature to K.
Lstar = Lstar/in2m; % Converts
rhocns = Pcns/R/Tcns;

%  Fluid property import
%py = pyenv(Version="C:\Users\Alex\Desktop\LADS-GIT-Repos\mainenv\Scripts\python.exe");
%Ethanoltables = twoPhaseFluidTables([-215.9,893.96],[0.001,3.0],25,25,60,'Ethanol','py.CoolProp.CoolProp.PropsSI');

%  ||/////////////////////////////
%% || Station solving          //
%  ||///////////////////////////
%  Solves for flow conditions at various stations within the nozzle.
[stat, mdot, epsilon] = stationsolvM(gamma,R,Pcns,Tcns,Pe,Mi,F,g,epsilonc);
Pinj = str2double(stat(2,2)); Tinj = str2double(stat(2,3)); rhoinj = str2double(stat(2,4)); vinj = str2double(stat(2,5)); Mc = str2double(stat(2,6)); Ac = str2double(stat(2,7)); Dc = str2double(stat(2,8));
Pi = str2double(stat(3,2)); Ti = str2double(stat(3,3)); rhoi = str2double(stat(3,4)); vi = str2double(stat(3,5)); Mi = str2double(stat(3,6)); 
Pt = str2double(stat(4,2)); Tt = str2double(stat(4,3)); rhot = str2double(stat(4,4)); vt = str2double(stat(4,5)); Mt = str2double(stat(4,6)); At = str2double(stat(4,7)); Dt = str2double(stat(4,8));
Pe = str2double(stat(5,2)); Te = str2double(stat(5,3)); rhoe = str2double(stat(5,4)); ve = str2double(stat(5,5)); Me = str2double(stat(5,6)); Ae = str2double(stat(5,7)); De = str2double(stat(5,8));

%  ||/////////////////////////////
%% || Geometry solving         //
%  ||///////////////////////////
%  Solves for nozzle geometry.
Vc = Lstar*At; % Finds chamber volume in m3.
syms Lcs;              % Sets the chamber length as a symbolic.
func = At*(Lcs*epsilonc+1/3*sqrt(At/pi)*cotd(thetacon)*(epsilonc^(1/3)-1))-Vc; % Solves for chamber barrel length in m.
Lcyl = real(vpasolve(func));                                  % Finds chamber length in m.
[F1,F2,F3,F4,F5,F6,P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v,R1] = RaoNozzleGeomMfs(Dc, Dt, De, Lcyl, R2rat, 40, epsilon, Lengthfrac);
[Ax,Ay,A] = chamberplot(P0,P1,P2,P3,P4,P5,P6,F1,F2,F3,F4,F5,F6,1,2,Ndiv); % Plots chamber area and nozzle profile.

%  ||///////////////////////////////
%% || Isentropic solving         //
%  ||/////////////////////////////
%  Solves isentropically for gas properties throughout the nozzle.

[Px,Tx,rhox,ax,vx,Vx,Dx,Mx] = IsenSolve(A,Ax,gamma,R,Pcns,Tcns,Pt,rhocns,At,mdot); % Solves isentropically for gas properties within the flow throughout the nozzle.

%  ||//////////////////////////
%% || Heat transfer         //
%  ||////////////////////////
%  Solves for heat transfer throughout the nozzle.

[z, Asz] = size(A);
fPx = fliplr(Px);
fTx = fliplr(Tx);
frhox = fliplr(rhox);
fax = fliplr(ax);
fvx = fliplr(vx);
fVx = fliplr(Vx);
fDx = fliplr(Dx);
fMx = fliplr(Mx);
fAx = fliplr(Ax);
fA = fliplr(A);


Prg = 4*gamma/(9*gamma-5); % Finds gas prandtl number.
Cpg = R/(1-1/gamma);       % Finds gas specific heat in J/kgK.
Rcurv = 1.882*Dt/4;        % Finds average radius of curvature of throat in m.
cstar = Pcns*At/mdot;      % Finds characteristic exit velocity in m/s.
mdotc = mdot/Nc/(1+of);    % Finds channel flow rate in kg/s.
Aet = .00201; Bet = 1614; Cet = .00618; Det = -1.132e-5;

%% Geometry and initial hot gas solving
for i = 1:1:Asz

% Area solving
thetac(i) = 360/Nc - 4*asind(tcw/(4*(fDx(i)+tc))); % Finds channel angle in degrees.
thetacw(i) = 2*asind(tcw/(4*(fDx(i)+tc)));         % Finds half-angle of inter-channel wall in degrees.
thetach(i) = thetac(i) - 2*thetacw(i);            % Finds angle taken up by channel itself in degrees.
Ac(i) = thetach(i)*pi/360*((fDx(i)+tc+wc)^2-(fDx(i)+tc)^2)+wc^2*sind(thetacw(i)); % Solves for channel angle in m2.
Pec(i) = 4*pi*thetach(i)/360*(2*fDx(i)+2*tc+wc)+2*wc;                            % Solves for channel perimeter in m2.
dhc(i) = 4*Ac(i)/Pec(i);                                                        % Finds hydraulic diameter in m.

% Hot gas side initial solving
mugI(i) = 46.6*10^(-10)*9/5*fTx(i)^.6*M^.5;                                                  % Finds viscosity in lb/in-s.
mug(i) = 46.6*10^(-10)*9/5*fTx(i)^.6*M^.5*39.3701/2.205;                                     % Finds viscosity in kg/m-s.
Reg(i) = frhox(i)*vx(i)*fDx(i)/(mug(i));                                          % Finds Reynolds number for gas.
if Reg(i)>4000                                                                  % Checks if flow is turbulent or laminar.
    r = Prg^.35;                                                                % If flow is turbulent, finds recovery factor.
else
    r = Prg^.5;                                                                 % If flow is laminar, finds recovery factor.
end
Taw(i) = Tcns*((1+r*((gamma-1)/2)*fMx(i)^2))/(1+(gamma-1)/2*fMx(i)^2);            % Finds adaibatic wall temp in K.

if i < Asz
dx(i) = abs(fAx(i+1) - fAx(i));
dy(i) = abs(fDx(i+1) - fDx(i));
else
    dx(i) = dx(i-1);
    dy(i) = dy(i-1);
end
SAch(i) = 2*pi*fDx(i)*sqrt(dx(i)^2+dy(i)^2)*thetach(i)/360;
end
%% Coolant passage design

%% Variable initialization
Tco(1) = 273.15; Twc(1) = 273.15;
syms Twgs; syms Twcs; syms qs;
fTaw = fliplr(Taw);
fSAch = fliplr(SAch);
fmug = fliplr(mug);
for i = 1:1:Asz
    Cpc(i) = 2.57e3; % Ethanol specific heat in j/kgK.
    rhoc(i) = 789; % Density of ethanol in kg/m3.
    vc(i) = mdotc/(rhoc(i)*Ac(i));
    muc(i) = Aet*exp(Bet/Tco(i)+Cet*Tco(i)+Det*Tco(i)^2);
    mucw = Aet*exp(Bet/Twcs+Cet*Twcs+Det*Twcs^2);
    Renc = rhoc(i)*vc(i)*dhc(i)/muc(i);
    Prc(i) = muc(i)*Cpc(i)/Keth;
    Nuc = 0.027*Renc^.8*Prc(i)^.4*(muc(i)/(Aet*exp(Bet/Twcs+Cet*Twcs+Det*Twcs^2))^.14);
    hc = Nuc*Keth/dhc(i);
    
    sigma = 1/((1/2*Twgs/Tcns*(1+(gamma-1)/2*fMx(i)^2)+1/2)^.68*(1+((gamma-1)/2)*fMx(i)^2)^.12); % Creates function for unitless function
    hg = 0.003*(.026/((Dt)^.2)*(fmug(i)^.2*Cpg/(Prg^.6))*(Pcns*g/cstar)^.8*(Dt/Rcurv)^.1)*(At/fA(i))^.9*sigma; % Finds gas HTC in W/m2K
    %0.0000203968*
    f1 = hc*(Twcs-Tco(i)) - qs;
    f2 = hg*(fTaw(i)-Twgs) - qs;
    f3 = Kss/tc*(Twgs-Twcs) - qs;
    if i <= 2
        [Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs]);
    else
        [Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs],[Twg(i-1),Twc(i-1),0]);
    end
    if i < Asz
    Tco(i+1) = q(i)*fSAch(i)/mdotc/Cpc(i) + Tco(i);
    %hgv(i) = hg(Twg(i));
    end
    fprintf('Coolant temp: %f\n',Tco(i));
end

%  ||//////////////
%% || Plotting  //
%  ||////////////

figure(3);
plot(Ax,Px);
title('Flow properties');
xlabel('Longitudinal position (m)');
ylabel('Pressure (Pa)');
hold on;
yyaxis right;
plot(Ax,Tx);
ylabel('Temperature (K)');
hold off;

figure(4);
plot(Ax,Mx);
title('Flow momentum properties');
xlabel('Longitudinal position (m)');
ylabel('Mach number');
hold on;
yyaxis right;
plot(Ax,vx);
ylabel('Velocity (m/s)');
hold off;

figure(5);
plot(Ax,Tx,Ax,fliplr(Taw));
title('Gas Properties');
xlabel('Longitudinal Position (m)');
ylabel('Temperature (K)');
hold on;
yyaxis right;
plot(Ax,fliplr(mug));
ylabel('Viscosity (Pa-s)');
hold off;
legend('Gas temp','Adiabat wall','Gas visc');

figure(6);
plot(Ax,fliplr(Ac));
title('Channel Velocity and area');
xlabel('Longitudinal position (m)');
ylabel('Area (m2)');
hold on;
yyaxis right;
plot(Ax,fliplr(vc));
ylabel('Velocity (m/s)');
hold off;

figure(7);
plot(Ax,Tx,Ax,Twg,Ax,fliplr(Twc),Ax,fliplr(Tco));
title('Channel Velocity and area');
xlabel('Longitudinal position (m)');
ylabel('Area (m2)');
legend('Gas','Gas-side wall','Coolant side wall','Coolant');