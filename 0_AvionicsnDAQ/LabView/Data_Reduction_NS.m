%%%%% CGT Data Reduction V0.1
%%%%% This program reduces calibration data into a usable amount, and may
%%%%% even calculate trendlines! (eventually)

% Start cleanup
close all;
clc;
clear;

%%%% Intro text
fprintf("#=====================//\n"); % Creates introductory text.
fprintf("# CGT Data Reduction //\n");  % 
fprintf("# V0.1 | 8/1/2024   //\n"); %
fprintf('#==================//\n'); %

%% User Input
DATin = input('Data filename: ', 's');
sensnum = input('Sensor number: ');
order = input('Polynomial trendline order: ');
fprintf('========================\n');
fprintf('Polynomial coefficients: ');

%% File Import
Fin = readtable(DATin);
Anum = 3+sensnum;

%% File segmentation
inVal = table2array(Fin(:,2));  % Seperates out input value.
Tstamp = table2array(Fin(:,1)); % Gets timestamp array.
AVal = table2array(Fin(:,Anum));  % Gets desired voltage input.

%% Data sorting
Ti = Tstamp(1,1);   % Gets initial timestamp.
Trel = Tstamp - Ti; % Gets relative time in s.
Aszz = size(Tstamp); % Gets array size.
Asz = Aszz(1);       % Simplifies array size.

%% Sequential data sorting

sct = 1;
j = 1;
ctac = 1;
ct = 1;
% Unique datapoint detector
for i = 1:1:(Asz)             % Iterates through all datapoints.
    if i == Asz               % Checks if on last datapoint
       detect(j) = inVal(i);  % Identifies unique inval for this dataset.
       ct(j) = sct-1;         % Identifies number of data points for this inval.
       icth(j) = i;
       ctl(j) = i - ct(j) + 1;
       Vavg(j) = mean(AVal(ctl(j):i)); % Takes average of voltage values for last setpoint.
    else
    if inVal(i) ~= inVal(i+1) && 1 ~= Asz  % Checks if next datapoint equals current - determines if inval changed.
        detect(j) = inVal(i);              % Stores unique inval value.
        if j == 1                          % Checks if iteration is on initial inval.
           ct(j) = sct;                    % Stores amount of data points for inval.
           ctl(j) = i - ct(j) + 1;         % Catches lower bound of average.
           Vavg(j) = mean(AVal(ctl(j):i)); % Takes average of voltage values for first setpoint.
        else
            ct(j) = sct-1;                  % Does the same as above, but specifically not for the 1st datapoint.           
            ctl(j) = i - ct(j) + 1;         % Catches lower bound of average.  
            Vavg(j) = mean(AVal(ctl(j):i)); % Takes average of voltage values for every non-first non-last setpoint.
        end
        sct = 1;                          % Resets set-counter.
        
        j = j+1;                          % Advances element counter.
    end
    end
    sct = 1 + sct;                        % Advances set counter.
end