function doPlotICAComponentLoadings(inputData,componentsToPlot,timeToPlot)

    % simple function to plot ICA component loadings
    % by Olave Krigolson
    % required input is an EEG lab data structure in which ICA has been run
    % and the number of components to plot and the amount of time (in
    % points) to plot expressed as two points - say [1001 to 2000].
    
    % compute activations (they are not computed automatically) - this 
    %W = weight*sphere;    % EEGLAB --> W unmixing matrix
    %icaEEG = W*Data;      % EEGLAB --> U = W.X activations    % MORE INFO
    % We plot EEG.icawinv (W-1) as these are the weights for the topographies,
    % - the inverse of the unmixing matrix W
    %see: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html
    %see; http://arnauddelorme.com/ica_for_dummies/
    if size(inputData.icaact,1) == 0
        inputData.icaact = (inputData.icaweights*inputData.icasphere)*inputData.data(inputData.icachansind,:);
    end
    
    icaTime = [timeToPlot(1):1:timeToPlot(2)];
    
    figure;
    
    nRows = 5;
    nCols = 5;
    
    if componentsToPlot < 5
        nRows = 2;
        nCols = 2;
    end
    if componentsToPlot > 4 & componentsToPlot < 10
        nRows = 3;
        nCols = 3; 
    end
    if componentsToPlot > 9 & componentsToPlot < 17
        nRows = 4;
        nCols = 4; 
    end        
     
    for componentCounter = 1:componentsToPlot
        subplot(nRows,nCols,componentCounter);
        eegData = [];
        eegData = inputData.data(componentCounter,timeToPlot(1):timeToPlot(2));
        plot(icaTime,eegData);
        hold on;
        icaData = [];
        icaData = inputData.icaact(componentCounter,timeToPlot(1):timeToPlot(2));
        plot(icaTime,icaData);
        [crossCor,lag] = xcorr(icaData,eegData,0,'coeff');
        hold off;
        title({['Component ' num2str(componentCounter)],['Cross Correlation: ' num2str(crossCor)]});
    end
    
end