function EEG = doRemoveOcularICAComponents(EEG)

    % a shell to run ICA ocular rejection with ICLabel
    % requires EEGLAB plugin firfilt
    % requires ICLabel (https://github.com/sccn/ICLabel)
    % requires matconvnet
    % (https://github.com/sccn/matconvnet)

    %% Perform IC rejection using the ICLabel EEGLAB extension.
    EEG = iclabel(EEG, 'default');
    
    %% Adding ocular correction here, CDH, 13 Jan 2022
    eyeLabel = find(strcmp(EEG.etc.ic_classification.ICLabel.classes,'Eye'));
    eyeI = EEG.etc.ic_classification.ICLabel.classifications(:,eyeLabel)  > 0.8;
    whichOnes = find(eyeI);
    
    % Remove ocular components
    EEG = pop_subcomp(EEG,whichOnes,0);
    EEG.numOcular = sum(eyeI);
    disp(['removing ' num2str(EEG.numOcular) ' ocular components']);

    % assign data quality values
    EEG.quality.ica.numberOfOcular = EEG.numOcular;
    EEG.quality.ica.icaClassifications = EEG.etc.ic_classification.ICLabel.classifications;
    EEG.quality.ica.averageBrain = mean(EEG.quality.ica.icaClassifications(:,1));

end