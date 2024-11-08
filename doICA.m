function [EEG] = doICA(EEG)

    computeActivations = 1;

    % the only required input is an EEG lab data structure. Again, this is
    % an EEGLAB shell. However, we do add the reconstruction of the ica
    % activations
 
    %EEG = pop_runica(EEG,'runica');
    EEG = pop_runica(EEG, 'icatype','picard','concatcond','on','options',{'pca',-1});
 
    % compute activations (they are not computed automatically) - this 
    %W = weight*sphere;    % EEGLAB --> W unmixing matrix
    %icaEEG = W*Data;      % EEGLAB --> U = W.X activations
    % MORE INFO
    %see: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html
    %see; http://arnauddelorme.com/ica_for_dummies/
    
    % the reason to make computing activations a flag is it doubles the
    % memory size of the EEG variable
    if computeActivations == 1
        EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    end

    % We plot EEG.icawinv (W-1) as these are the weights for the topographies,
    % - the inverse of the unmixing matrix W

end