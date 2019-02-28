function doICAPlotComponents(inputData,componentsToPlot);

    % simple function to plot ICA components
    % by Olave Krigolson
    % required input is an EEG lab data structure in which ICA has been run
    % and the number of components to plot
    
    warning('off','all');
    
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
        subplot_tight(nRows,nCols,componentCounter);
        topoplot(inputData.icawinv(:,componentCounter), inputData.chanlocs, 'verbose','off','style','fill','chaninfo',inputData.chaninfo,'numcontour',8);
        title(['Component ' num2str(componentCounter)]);
    end
        
end