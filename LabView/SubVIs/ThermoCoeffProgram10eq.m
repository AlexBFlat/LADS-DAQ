clear; clc; close all;
%%%% Thermocuple coefficient program

% Below numbers for a Creality NTC 100K 3965 from tables
T1 = 269.25; 
T2 = 296.45; 
T3 = 311.75; 
T4 = 337.75;
T5 = 338.65;
T6 = 339.95;
T7 = 340.75;
T8 = 343.15;
T9 = 345.65;
T10 = 348.15;

R1 = 138943.702;  % Data point 1 resistance in Ohms.
R2 = 93205.1904;  % Data point 2 resistance in Ohms.
R3 = 37912.5266;  % Data point 3 resistancei n Ohms.
R4 = 17792.1372;
R5 = 17379.1614;
R6 = 16524.7013;
R7 = 15988.824;
R8 = 14344.3823;
R9 = 12100.362;
R10 = 10321.9885;

%%% Solving
out1 = steinhart(T1, T2, T3, R1, R2, R3);
A1 = real(out1(1)); B1 = real(out1(2)); C1 = real(out1(3));


%%% Output
fprintf('Thermistor:\nA1: %f B1: %f C1: %f\n\n', A1, B1, C1);


%%% Function steinhart calculates the A, B, C, and D coefficients for given
%%% thermistors.
function out = steinhart(T1, T2, T3, R1, R2, R3)
    syms A B C; % Establishes symbolic variables.

    func1 = A + B*log(R1) + C*(log(R1))^3 - 1/T1; % Creates function 1.
    func2 = A + B*log(R2) + C*(log(R2))^3 - 1/T2; % Creates function 2.
    func3 = A + B*log(R3) + C*(log(R3))^3 - 1/T3; % Creates function 3.

    outmat = vpasolve(func1, func2, func3); % Solves system of equations for A, B, and C. Returns to function output.
    Ao = outmat.A; Bo = outmat.B; Co = outmat.C;
    out = [Ao Bo Co];
end