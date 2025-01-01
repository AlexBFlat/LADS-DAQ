clear; close all; clc;
%% Introduction
fprintf(['/////////////////////////////////////\n' ...
         'Parametric Nozzle Design Program ///\n' ...
         'Version: 0.00 Updated: 1/1/2025 ///\n' ...
         '//////////////////////////////////\n'])

%  ||/////////////////
%% || Input values //
%  ||///////////////
%  Design input values
py = pyenv(Version="C:\Users\Alex\Desktop\LADS-GIT-Repos\mainenv\Scripts\python.exe");

r134aTables = twoPhaseFluidTables([80,500],[0.001,3],25,25,60,'R134a','py.CoolProp.CoolProp.PropsSI');