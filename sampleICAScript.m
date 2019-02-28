clear all;
close all;
clc;

% load a test set of data where an extended ICA has already been run on the
% continuous data
load('sampleEEGDataPostICA.mat');

preICASampleData = icaEEG.data(35,1001:2000);

doPlotICAComponents(icaEEG,25);
doPlotICAComponentLoadings(icaEEG,16,[1001 2000]);

componentsToRemove = [1];
[icaEEG] = doRemoveICAComponents(icaEEG,componentsToRemove);

% plot the pre ICA data on channel 35 and compare it with post ICA data on
% channel 35
figure;
time = [1:1:1000];
plot(time,preICASampleData,'LineWidth',3);
hold on;
plot(time,icaEEG.data(35,1001:2000),'LineWidth',3);
hold off;
title('Comparison of pre ICA (blue) and post ICA (red) EEG data');