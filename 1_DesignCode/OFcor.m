function [T,Isp] = OFcor(of)
I7 = -6.4826; I6 = 116.2332; I5 = -870.364; I4 = 3512.476; I3 = -8188.81; I2 = 10882.7; I1 = -7453.14; I0 = 2181.416;
T7 = -108.355; T6 = 1695.513; T5 = -11052.4; T4 = 38600.31; T3 = -76934.2; T2 = 85083.61; T1 = -45155.9; T0 = 10223.23;

T = T7*of^7 + T6*of^6 + T5*of^5 + T4*of^4 + T3*of^3 + T2*of^2 + T1*of + T0;
Isp = I7*of^7 + I6*of^6 + I5*of^5 + I4*of^4 + I3*of^3 + I2*of^2 + I1*of + I0;
end