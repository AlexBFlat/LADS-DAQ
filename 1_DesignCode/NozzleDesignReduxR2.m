%  ||//////////////////////////////
%% || Initializations and setup //
%  ||////////////////////////////
%  Design input values
% Update to use non-constant density and specific heat!
% Deal with fins
% Current nusselt corellation is not valid, is limited to above 10000 (0.027)
% 1. Variable specific heat
% 2. Variable density
% 3. Nusselt corellation for laminar in chat chat
% 4. Deal with fins 
% 5. Update chamber volume approximation to deal with fillet!
% 6. Add pressure drop (maybe) and correction from paper

clear; close all; clc;
%% Introduction
fprintf(['/////////////////////////////////////\n' ...
         'Parametric Nozzle Design Program ///\n' ...
         'Version: 0.01 Updated: 1/4/2025 ///\n' ...
         '//////////////////////////////////\n'])

%  ||/////////////////////////////////////////
%% || O/F Isp and Tc corellation constants //
%  ||///////////////////////////////////////

%  ||/////////////////
%% || Input values //
%  ||///////////////
%  Design input values
% Engine performance
F = 150;          % Thrust in lb (69kg).
%Isp = 261;  % Isp in seconds.
of = 1.1;      % Oxidizer to fuel ratio.
[Tcns, Isp] = OFcor(of);
epsilonc = 22.5;
%epsilonc = 22.5; % Chamber area ratio.
thetacon = 50;   % converging section angle in degrees.
% Engine pressures
Pc = 420;        % Chamber pressure in psia.
Pe = 14.7;       % Exit pressure in psia.
% Engine temperatures
Tco(1) = 273.15; % Initial coolant bulk temperature in K.
%Tcns = 5802.507; % Chamber temperature in R.

% Engine mach numbers
Mi = .0459;      % Sets nozzle inlet mach number.
% Geometric constants
R2rat = 1.5;     % Ratio of R2 to Rt.
Lengthfrac = 80; % Rao nozzle length fraction in percent.
Ndiv = 120;
Nc = 30;         % Number of channels
tc = .8e-3;       % Thickness of chamber wall in meters.
tcw = 1e-3;      % Thickness of channel wall in meters.
wc = .8e-3;       % Channel heigh in meters.
% Environmental constants
g = 9.81;        % Acceleration due to gravity in m/s2.
gamma = 1.1598;  % Gamma of combustion gasses.
M = 22.2429;     % Molar mass of combustion gasses in kmol.
Ro = 8.31436e3;    % Universal gas constant in J/kmol/K
R = Ro/M;        % Gas constant in J/kgK.
Lstar = 63.27;   % Sets L star in inches, the characteristic nozzle length for ethanol.
Keth = .167;      % Thermal conductivity of ethanol in W/mK.
Kss = 15;        % Thermal conductivity of stainless steel in W/mk.
%rhoeth = 789;    % Density of ethanol in kg/m3.
%Cpeth(i) = 2.57e3;  % Specific heat of ethanol in J/kgK.
Prg = .52;       % Prandtl number from RPA.

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
F = lb2N*F;           % Converts thrust to N.
Pcns = Psi2Pa*Pc;     % Converts chamber pressure to Pa.
Pe = Psi2Pa*Pe;       % Converts exit pressure to Pa.
%Tcns = Tcns*R2K;     % Converts chamber temperature to K.
Lstar = Lstar/in2m;   % Converts L star to m.
rhocns = Pcns/R/Tcns; % Stagnation density in kg/m3.
Cpm2CpI = 4184;       % Conversion of metric specific heat to imperal.

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
Lcyl = real(vpasolve(func));                                                   % Finds chamber length in m.
[F1,F2,F3,F4,F5,F6,P0,P1, P2, P3, P4, P5, P6, F1v, F2v, F3v, F4v, F5v, F6v,R1] = RaoNozzleGeomMfs(Dc, Dt, De, Lcyl, R2rat, 40, epsilon, Lengthfrac);
[Ax,Ay,A] = chamberplot(P0,P1,P2,P3,P4,P5,P6,F1,F2,F3,F4,F5,F6,1,2,Ndiv);      % Plots chamber area and nozzle profile.

%  ||///////////////////////////////
%% || Isentropic solving         //
%  ||/////////////////////////////
%  Solves isentropically for gas properties throughout the nozzle.

[Px,Tx,rhox,ax,vx,Vx,Dx,Mx] = IsenSolve(A,Ax,gamma,R,Pcns,Tcns,Pt,rhocns,At,mdot); % Solves isentropically for gas properties within the flow throughout the nozzle.

%  ||//////////////////////////
%% || Heat transfer         //
%  ||////////////////////////
Au = .00201e-3; Bu = 1614; Cu = .00618; Du = -1.132e-5;
mdotc = mdot/(1+of)/Nc; % Finds channel flowrate in kg/s.
[z,Asz] = size(A);      % Grabs the size of the chamber areas array.
AA = fliplr(A);         % Creates a reversed array of the area throughout the chamber.
AAx = fliplr(Ax);       % Creates a flipped longitudinal position array.
AAy = fliplr(Ay);       % Creates a flipped radius array.
MMx = fliplr(Mx);       % Finds flipped mach number.
TTx = fliplr(Tx);       % Finds flipped gas temp.
vvx = fliplr(vx);       % Finds flipped gas velocity.
thetac = 360/Nc;  % initializes a theta storage array.
thetacw = zeros(1,Asz); % Initializes wall half-angle array.
thetach = zeros(1,Asz); % Initializes cooled segment angle array.
Ach = zeros(1,Asz);     % Initializes channel area array.
Pch = zeros(1,Asz);     % Initializes channel perimeter array.
dch = zeros(1,Asz);     % Initializes hydraulic diameter array.
vc = zeros(1,Asz);      % Initializes channel velocity array.
Rec = zeros(1,Asz);     % Initializes channel velocity array.
Tco = zeros(1,Asz);     % Initializes channel velocity array.
Taw = zeros(1,Asz);     % Initializes adiabatic wall temp array. 
mug = zeros(1,Asz);     % Initializes gas viscosity array.
mugI = zeros(1,Asz);     % Initializes gas viscosity array.
Reg = zeros(1,Asz);     % Initializes gas reynolds number.
Prc = zeros(1,Asz);     % Initializes fluid prandtl number.
%muc = @(T) Au*exp(Bu/T+Cu*T+Du*T^2); % Function for ethanol viscosity in Pa-s.
%Prg = 4*gamma/(9*gamma-5);
syms Twgs Twcs qs;
Tco(1) = 293.15;
Cpg = R/(1-1/gamma);                                            % Gas specific heat in J/kgK.
cstar = sqrt(R*Tcns/gamma*((gamma+1)/2)^((gamma+1)/(gamma-1))); % Characteristic velocity in m/s.
cstarI = cstar*in2m/12;                                         % Finds characteristic velocity in ft/s.
gI = 32.2;                                                 % Finds acceleration due to gravity in ft/s2.
PcnsI = Pcns/Psi2Pa;                                            % Chamber stag. pressure in psia.
CpI = Cpg/Cpm2CpI;                                              % SPecific heat in imperial units.
DtI = Dt*in2m;
for i = 1:1:Asz
% Area solving
    rhoeth(i) = Tco(i)^2*-.00458+Tco(i)*2.188704+538.3445;
    Cpeth(i) = Tco(i)^4*1.24703e-5+Tco(i)^3*-.01818+Tco(i)^2*9.82362+Tco(i)*-2320.48+204335.2;
    thetacw(i) = 2*asind(tcw/(4*(AAy(i)+tc))); % Finds channel half-angle in degrees.
    thetach(i) = thetac - 2*thetacw(i);        % Finds cooled segment half angle in degrees.
    Ach(i) = thetach(i)/360*pi*((AAy(i)+tc+wc)^2-(AAy(i)+tc)^2) + wc^2*sind(thetacw(i)); % Finds channel area in m2.
    Pch(i) = 2*pi*thetach(i)/360*(2*AAy(i)+2*tc+wc)+2*wc;                                % Finds channel perimeter in m.
    dch(i) = 4*Ach(i)/Pch(i);                                                            % Finds hydraulic diamter in m.
% Chamber gas solving
    %mug(i) = 46.6*10^(-10)*9/5*TTx(i)^.6*M^.5*39.3701/2.205;                      % Finds viscosity in kg/m-s.
    mug(i) = 1.0405e-4;
    %mugI(i) = mug(i)*g/lb2N*in2m;
    mugI(i) = .05599*mug(i);
    Reg(i) = rhox(i)*vvx(i)*AAy(i)/mug(i);                                          % Finds Reynolds number for gas.
    if Reg(i)>4000                                                                  % Checks if flow is turbulent or laminar.
        r = Prg^.33;                                                                % If flow is turbulent, finds recovery factor.
    else
        r = Prg^.5;                                                                 % If flow is laminar, finds recovery factor.
    end
    Taw(i) = Tcns*((1+r*((gamma-1)/2)*MMx(i)^2))/(1+(gamma-1)/2*MMx(i)^2); 
% Channel flow conditions
    vc(i) = mdotc/(rhoeth(i)*Ach(i)); % Finds channel velocity in m/s.
    %Tco(i) = 300;                                        % Coolant bulk temperature in K.
    muc = Au*exp(Bu/Tco(i)+Cu*Tco(i)+Du*Tco(i)^2);
    mucw = Au*exp(Bu/Twcs+Cu*Twcs+Du*Twcs^2);
    Rec = rhoeth(i)*vc(i)*dch(i)/muc;               % Reynolds number in cooling channel.
    Prc = muc*Cpeth(i)/Keth;                        % Prandtl number in cooling channel.
    Nuc =  .027*Rec^.8*Prc^.4*(muc/mucw)^.14; % Finds nusselt number. Symbolic.
    hc = Keth*Nuc/dch(i);                                   % Coolant side HTC.
    sigma = 1/((1/2*Twgs/Tcns*(1+(gamma-1)/2*MMx(i)^2)+1/2)^.68*(1+(gamma-1)/2*MMx(i)^2)^.12);
    %hg = 2943444.1131*((0.026/(DtI^.2)*(mugI(i)^.2*CpI/(Prg^.6))*(PcnsI*gI/cstarI)^.8*(DtI/(1.882*DtI/4))^.1)*(At/AA(i))^.9*sigma);
    hg = 2943444.1131*((0.026/(DtI^.2)*(mugI(i)^.2*CpI/(Prg^.6))*(PcnsI*gI/cstarI)^.8*((DtI/(1.882*DtI/4))^.1)*(At/AA(i))^.9))*sigma;
    %2943444.113*
    f1 = hg*(Taw(i)-Twgs)-qs;
    f2 = Kss/tc*(Twgs-Twcs) - qs;
    f3 = hc*(Twcs-Tco(i)) - qs;
    if i <= 2
    [Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs]);
    else
    [Twg(i),Twc(i),q(i)] = vpasolve([f1,f2,f3],[Twgs,Twcs,qs],[Twg(i-1),Twc(i-1),1e7]);
    end
    %Twc(i) = 500; Twg(i) = 1000; q(i) = 2000;
    if i ~= Asz
    dx(i) = AAx(i+1)-AAx(i);
    dy(i) = AAy(i+1)-AAy(i);
    SAch(i) = 2*pi*AAy(i)*sqrt(dx(i)^2+dy(i)^2)*thetac/360;
    Tco(i+1) = q(i)/mdotc/Cpeth(i)*SAch(i)+Tco(i);
    else
    end
    Nucv(i) =  .027*Rec^.8*Prc^.4*((Au*exp(Bu/Tco(i)+Cu*Tco(i)+Du*Tco(i)^2))/(Au*exp(Bu/Twc(i)+Cu*Twc(i)+Du*Twc(i)^2)))^.14;
    hcv(i) = Keth*Nucv(i)/dch(i);
    %2943444.1131*
    sigmav(i) = 1/((1/2*Twg(i)/Tcns*(1+(gamma-1)/2*MMx(i)^2)+1/2)^.68*(1+(gamma-1)/2*MMx(i)^2)^.12);
    hgv(i) = 2943444.1131*(0.026/(DtI^.2)*(mugI(i)^.2*CpI/(Prg^.6))*(PcnsI*gI/cstarI)^.8*((DtI/(1.882*DtI/4))^.1)*(At/AA(i))^.9)*sigmav(i);
    %hgv(i) = hg;
    fprintf('Channel viscosity: %f Re: %f Pr: %f Nuc: %f hc: %f hg: %f sigma: %f\n',muc,Rec,Prc,Nucv(i),hcv(i),hgv(i),sigmav(i));
end
thetach = fliplr(thetac);
Ach = fliplr(Ach);
dch = fliplr(dch);
Pch = fliplr(Pch);
vc = fliplr(vc);
Rec = fliplr(Rec);
Taw = fliplr(Taw);
Twg = fliplr(Twg);
Twc = fliplr(Twc);
Tco = fliplr(Tco);
q = fliplr(q);

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
plot(Ax,Ach);
title('Channel geometry properties');
xlabel('Longitudinal position (m)');
ylabel('Channel area (m2)');
hold on;
yyaxis right;
plot(Ax,dch);
ylabel('Hydraulic diameter (m)');
hold off;

figure(6);
plot(Ax,vc,Ax,Prc);
title('Channel flow characteristics');
xlabel('Longitudinal position (m)');
ylabel('channel velocity (m/s)');
hold on;
yyaxis right;
plot(Ax,Rec);
ylabel('Coolant reynolds number');
hold off;
legend('Channel velocity','Channel Reynolds number','Channel Prandtl number');

figure(7);
plot(Ax,Tx);
title('Combustion gas properties');
xlabel('Longitudinal position (m)');
ylabel('Gas temperature (K)');
hold on;
yyaxis right;
plot(Ax,Taw);
ylabel('Adiabatic wall temp (K)');
hold off;

Smelt = linspace(1670,1670,Asz);
figure(8);
plot(Ax,Smelt,Ax,Taw,Ax,Twg,Ax,Twc,Ax,Tco);
title('Chamber heat transfer');
xlabel('Longitudinal position (m)');
ylabel('Gas-side temperatures (K)');
legend('Steel melting temperature','Adiabatic wall','Gas-side wall','Coolant-side wall','Coolant bulk');