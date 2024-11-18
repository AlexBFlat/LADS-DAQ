clear; close all; clc;
%%%% Nescius Injector Design Code

%% Engine constants, imported from RPA analysis
% Design Parameters
psi2pa = 6894.76;    % Conversion for psi to pa.
lb2N = 4.448;        % Conversion for lbf to N.
Pcns = 420 * psi2pa; % Chamber stagnation pressure in Pa.
F = 69;              % Thrust in N.
OF = 1.5;            % Oxidizer to fuel ratio.
rhoLOX = 1141;       % Liquid Oxygen density in kg/m3.
rhoETH = 789;        % Ethanol density in kg/m3.




