clear; clc; close all;
%%%% Thermocuple coefficient program

% Below numbers for a Creality NTC 100K 3965 from tables
T1 = 306.5389; % Data point 1 temperature in K.
T2 = 302.2611; % Data poont 2 temperature in K.
T3 = 295.7611; % Data point 3 temperature in K. 

R1 = 0.8837e5;  % Data point 1 resistance in Ohms.
R2 = 0.8320e5;  % Data point 2 resistance in Ohms.
R3 = 1.0453e5;  % Data point 3 resistancei n Ohms.

R21 = 22054.639;  % Data point 1 resistance in Ohms.
R22 = 6303.853879;  % Data point 2 resistance in Ohms.
R23 = 1026.095515;  % Data point 3 resistancei n Ohms.

R31 = 22051.76591;  % Data point 1 resistance in Ohms.
R32 = 6295.161641;  % Data point 2 resistance in Ohms.
R33 = 1229.563;  % Data point 3 resistancei n Ohms.

%%% Solving
out1 = steinhart(T1, T2, T3, R1, R2, R3);
A1 = real(out1(1)); B1 = real(out1(2)); C1 = real(out1(3));

out2 = steinhart(T1, T2, T3, R21, R22, R23);
A2 = real(out2(1)); B2 = real(out2(2)); C2 = real(out2(3));

out3 = steinhart(T1, T2, T3, R31, R32, R33);
A3 = real(out3(1)); B3 = real(out3(2)); C3 = real(out3(3));

%%% Output
fprintf('Thermistor 1:\nA1: %f B1: %f C1: %f\n\n', A1, B1, C1);
fprintf('Thermistor 2:\nA2: %f B2: %f C2: %f\n\n', A2, B2, C2);
fprintf('Thermistor 3:\nA3: %f B3: %f C3: %f\n', A3, B3, C2);

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