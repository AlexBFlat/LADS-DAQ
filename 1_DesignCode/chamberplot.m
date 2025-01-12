
%% Function chamberplot plots the chamber given functions from RaoNozzleGeomRedux
function [Ax,Ay,A] = chamberplot(P0,P1,P2,P3,P4,P5,P6,F1,F2,F3,F4,F5,F6,fig1,fig2,Ndiv)
z = 0; % Storage variable.
Ltot = -P0(1)+P6(1);
L1 = -P0(1)+P1(1);  % Finds x length of the segment of f1.
p1 = L1/Ltot;       % Finds the percent of nozzle length f1 takes up.
N1 = round(Ndiv*p1);
L2 = -P1(1)+P2(1);  % Finds x length of the segment of f2.
p2 = L2/Ltot;       % Finds the percent of nozzle length f2 takes up.
N2 = round(Ndiv*p2);
L3 = -P2(1)+P3(1);  % Finds x length of the segment of f3.
p3 = L3/Ltot;       % Finds the percent of nozzle length f3 takes up.
N3 = round(Ndiv*p3);
L4 = -P3(1);        % Finds x length of segment of f4.
p4 = L4/Ltot;       % Finds the percent of nozzle length f4 takes up.
N4 = round(Ndiv*p4);
L5 = P5(1);         % Finds x length of segment of f5.
p5 = L5/Ltot;       % Finds the percent of nozzle length f5 takes up.
N5 = round(Ndiv*p5);
L6 = P6(1) - P5(1); % Finds x length of segment of f6.
p6 = L6/Ltot;       % Finds the percent of nozzle length f6 takes up.
N6 = round(Ndiv*p6);

%% Isentropic flow solving
% Nozzle area solving
Lco = P6(1) + abs(P0(1)); % Finds the total chamber length in inches.
Leo = P6(1);              % Finds the total nozzle length in inches.
L = Lco + Leo;            % Finds total length of chamber in inches.
%% F1 area solving
% From P0 to P1
A1x = double(linspace(P0(1),P1(1),N1));         % Finds area X values for F1.
A1 = double(pi.*(linspace(F1(1),F1(1),N1)).^2); % Finds area Y values for F1.
[z,A1sz] = size(A1);                              % Finds size of area array.
%% F2 area solving
% From P1 to P2
A2x = double(linspace(P1(1),P2(1),N2)); % Finds area X values for F2.
A2 = double(pi.*(F2(A2x)).^2);            % Finds area Y values for F2.
[z,A2sz] = size(A2);                      % Finds size of area array.
%% F3 area solving
% From P2 to P3
A3x = double(linspace(P2(1),P3(1),N3)); % Finds X area values for F3.
A3 = double(pi.*(F3(A3x)).^2);            % Finds Y area values for F3.
[z,A3sz] = size(A3);                      % Finds size of area array.
%% F4 area solving
% From P3 to P4
A4x = double(linspace(P3(1),P4(1),N4)); % Finds X area values for F4.
A4 = double(pi.*(F4(A4x)).^2);            % Finds Y area values for F4.
[z,A4sz] = size(A4);                      % Finds size of area array.

%% F5 area solving
% From P4 to P5
A5x = double(linspace(P4(1),P5(1),N5)); % Finds X area values for F5.
A5 = double(pi.*(F5(A5x)).^2);            % Finds Y area values for F5.
[z,A5sz] = size(A5);                      % Finds size of area array.

%% F6 area solving
% From P5 to P6
A6x = double(linspace(P5(1),P6(1),N6+5)); % Finds X area values for F6.
A6 = double(pi.*(F6(A6x)).^2);            % Finds Y area values for F6.
[z,A6sz] = size(A6);                      % Finds size of area array.

tol = 0.01;
%% Area function stitching
A = [A1, A2(2:A2sz), A3(2:A3sz), A4(2:A4sz), A5(2:A5sz), A6(2:A6sz)];        % Stiches the area values into a continues array of area values.
[z, Asz] = size(A);                                                          % Finds size of Area array.
Ax = [A1x, A2x(2:A2sz), A3x(2:A3sz), A4x(2:A4sz), A5x(2:A5sz), A6x(2:A6sz)]; % Sets x values for area array.
Ay = sqrt(A./pi);

figure(fig1);
plot(Ax,A);
title('Chamber area');
xlabel('Longitudinal position (m)');
ylabel('Area (m^2)');

figure(fig2);
plot(Ax,Ay,Ax,-Ay);
title('Chamber geometry');
xlabel('Longitudinal position (m)');
ylabel('Radius (m)');
axis equal;
end