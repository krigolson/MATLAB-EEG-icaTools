clear all;
close all;
clc;

% command to run ICA via EEGLAB (already implemented in preprocess data)
%EEG = pop_runica(EEG, 'extended',1);

% amount of data to visualize
pointToPlot = 10000;

componentsToPlot = [1 2 3 4 5 6];
 
load('Subject_1_ICA_cont.mat');
 
% compute activations (they are not computed automatically) - this 
%W = weight*sphere;    % EEGLAB --> W unmixing matrix
%icaEEG = W*Data;      % EEGLAB --> U = W.X activations
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
% MORE INFO
%see: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html
%see; http://arnauddelorme.com/ica_for_dummies/

% We plot EEG.icawinv (W-1) as these are the weights for the topographies,
% - the inverse of the unmixing matrix W
componentCounter = 1;
for i = 1:2:11
    currentComponent = componentsToPlot(componentCounter);
    subplot_tight(6,2,i);
    topoplot(EEG.icawinv(:,currentComponent), EEG.chanlocs, 'verbose','off','style','fill','chaninfo',EEG.chaninfo,'numcontour',8);
    subplot_tight(6,2,i+1);
    timeData = 1:1:pointToPlot;
    icaData = squeeze(EEG.icaact(currentComponent,1:pointToPlot));
    plot(timeData,icaData);
    hold on;
    eegData = squeeze(EEG.data(1,1:pointToPlot));
    plot(timeData,eegData);
    [crossCor,lag] = xcorr(icaData,eegData,0,'coeff');
    title(['Cross Correlation: ' num2str(crossCor)]);
    hold off;
    componentCounter = componentCounter + 1 ;
end