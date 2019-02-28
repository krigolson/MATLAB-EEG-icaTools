function [EEG] = doRemoveICAComponents(EEG,componentsToRemove)

    % simple function to remove ICA components
    % by Olav Krigolson
    
    % command to run ICA via EEGLAB (already implemented in preprocess data)
    %EEG = pop_runica(EEG, 'extended',1);
    % compute activations (they are not computed automatically) - this 
    %W = weight*sphere;    % EEGLAB --> W unmixing matrix
    %icaEEG = W*Data;      % EEGLAB --> U = W.X activations    % MORE INFO
    % We plot EEG.icawinv (W-1) as these are the weights for the topographies,
    % - the inverse of the unmixing matrix W
    %see: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html
    %see; http://arnauddelorme.com/ica_for_dummies/
    if size(EEG.icaact,1) == 0
        EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    end
    
    EEG.icaact(componentsToRemove,:) = 0;           % suppress artifacts
    EEG.data = EEG.icawinv*EEG.icaact;                     % reconstruct data
    
end