clear all;
close all;
clc;

% by Olav Krigolson

% if you want to run the ICA itself uncomment the lines below and do not
% load the ICA processed data. Or, in the interest of speed you can just
% load the ICA processed data. Note, this is raw data with no pre
% processing. See samplePreprocessingScriptWithICA for a full analysis.

%load('sampleEEGData.mat');
%[icaEEG] = doICA(EEG,0);

% load a test set of data where an extended ICA has already been run on the
% continuous data
load('sampleEEGDataPostICA.mat');

preICASampleData = icaEEG.data(35,1001:2000);

doICAPlotComponents(icaEEG,25);
doICAPlotComponentLoadings(icaEEG,16,[1001 2000]);

componentsToRemove = [1];
[icaEEG] = doICARemoveComponents(icaEEG,componentsToRemove);

% plot the pre ICA data on channel 35 and compare it with post ICA data on
% channel 35
figure;
time = [1:1:1000];
plot(time,preICASampleData,'LineWidth',3);
hold on;
plot(time,icaEEG.data(35,1001:2000),'LineWidth',3);
hold off;
title('Comparison of pre ICA (blue) and post ICA (red) EEG data');