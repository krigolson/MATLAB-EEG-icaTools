function inverseICA
    
    global message1
    global message3
    global icaData
    global f1
    global f2

    % command to run ICA via EEGLAB (already implemented in preprocess data)
    %EEG = pop_runica(EEG, 'extended',1);
    
    [filename, pathname, filterindex] = uigetfile('*.*','Pick a preprocessed file that has had ICA run on it:');
    
    load(filename);

    % amount of data to visualize
    EEG.icaT1 = 1000;
    EEG.icaT2 = 10000;
    EEG.icaTWidth = EEG.icaT2 - EEG.icaT1;
    EEG.allComponents = EEG.icachansind;
    EEG.selectedComponents = 1;
    EEG.icaChannel = 1;
    
    % compute activations (they are not computed automatically) - this 
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    %W = weight*sphere;    % EEGLAB --> W unmixing matrix
    %icaEEG = W*Data;      % EEGLAB --> U = W.X activations    % MORE INFO
    % We plot EEG.icawinv (W-1) as these are the weights for the topographies,
    % - the inverse of the unmixing matrix W
    %see: http://www.mat.ucm.es/~vmakarov/Supplementary/wICAexample/TestExample.html
    %see; http://arnauddelorme.com/ica_for_dummies/

    scrsz = get(groot,'ScreenSize');

    fig1 = figure(1);
    bottom = 50;

    btn1 = uicontrol('Style','pushbutton', 'String', 'Quit','Position',[scrsz(3)-200 bottom 100 20],'Callback',@quitLoop);
    btn1.BackgroundColor = 'w';
    btn2 = uicontrol('Style','pushbutton', 'String', 'Save Data','Position',[scrsz(3)-200 bottom+25 100 20],'Callback',@saveData);
    btn2.BackgroundColor = 'w';
    btn3 = uicontrol('Style', 'listbox','Position',[scrsz(3)-560 bottom 100 100],'string',EEG.allComponents,'Max',max(EEG.allComponents),'Min',1,'Callback',@selectComponents);
    btn3.BackgroundColor = 'w';
    btn4 = uicontrol('Style','pushbutton', 'String', 'Set Time Range','Position',[scrsz(3)-200 bottom+50 100 20],'Callback',@setTimeWindow);
    btn4.BackgroundColor = 'w';
    btn5 = uicontrol('Style', 'popup','String', {EEG.chanlocs.labels},'Position',[scrsz(3)-700 bottom 100 100],'Callback', @setICAChannel);
    btn5.Value = 35;
    btn5.BackgroundColor = 'w';
    
    txt1 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom 200 20],'String',message1,'HorizontalAlignment','left');
    txt1.BackgroundColor = 'w';
    txt2 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+25 200 20],'String','Selected Components','HorizontalAlignment','left');
    txt2.BackgroundColor = 'w';
    txt3 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+50 200 20],'String',message3,'HorizontalAlignment','left');
    txt3.BackgroundColor = 'w';
    txt4 = uicontrol('Style','text','Position',[scrsz(3)-425 bottom+75 200 20],'String','Current Time Range','HorizontalAlignment','left');
    txt4.BackgroundColor = 'w';
    txt5 = uicontrol('Style','text','Position',[scrsz(3)-700 bottom+110 100 20],'String','Current Channel','HorizontalAlignment','left');
    txt5.BackgroundColor = 'w';
    txt6 = uicontrol('Style','text','Position',[scrsz(3)-560 bottom+110 110 20],'String','Select Components','HorizontalAlignment','left');
    txt6.BackgroundColor = 'w';
    
    redoMath;
    plotComponents;
    
    function redoMath

        icaData = [];
        icaData(1:EEG.icaTWidth+1) = 0;
        if length(EEG.selectedComponents) > 0
            for icaCounter = 1:length(EEG.selectedComponents)
                icaData = icaData + squeeze(EEG.icaact(EEG.selectedComponents(icaCounter),EEG.icaT1:EEG.icaT2));
            end
        end
        
        icaTempAcct = [];
        icaTempAcct = EEG.icaact;                           % replicate the activations
        icaTempAcct(EEG.selectedComponents,:) = 0;          % suppress artifacts
        EEG.reconstructedEEG = EEG.icawinv*icaTempAcct;                          % rebuild data
        
        message3 = [num2str(EEG.icaT1) ' to ' num2str(EEG.icaT2)];
        
        set(txt3, 'String', message3);

    end
    
    function plotComponents(source,event)
        
        delete(f1);
        delete(f2);
        
        componentCounter = 1;
        for i = 1:12
            subplot_tight(4,4,i);
            topoplot(EEG.icawinv(:,i), EEG.chanlocs, 'verbose','off','style','fill','chaninfo',EEG.chaninfo,'numcontour',8);
            title(['Component ' num2str(i)]);
        end
        
        f1 = subplot_tight(4,4,13);
        timeData = [];
        timeData = EEG.icaT1:1:EEG.icaT2;
        eegData = [];
        eegData = squeeze(EEG.data(EEG.icaChannel,EEG.icaT1:EEG.icaT2));
        plot(timeData,eegData);
        title('EEG Data (BLUE) compared to ICA Component Activation (RED)');
        hold on;
        if sum(icaData) ~= 0
            plot(timeData,icaData);
            [crossCor,lag] = xcorr(icaData,eegData,0,'coeff');
            xlabel(['Cross Correlation: ' num2str(crossCor)]);
            EEG.icaCrossCor = crossCor;
        end
        hold off;
        
        f2 = subplot_tight(4,4,14);
        reconstructPlotData = squeeze(EEG.reconstructedEEG(EEG.icaChannel,EEG.icaT1:EEG.icaT2));
        plot(timeData,eegData);
        title('EEG Data (BLUE) compared to Reconstructed EEG Data (RED)');
        hold on;
        if sum(icaData) ~= 0
            plot(timeData,reconstructPlotData);
        end
        hold off;
        
    end

    function saveData(source,event)
        
        uiwait(msgbox('SAVED DATA WILL HAVE COMPONENTS SUBTRACTED!','WARNING!!!','modal'));

        prompt = {'Enter the filename:'};
        dlg_title = 'Save Data';
        num_lines = 1;
        defaultans = {filename};
        answer{1} = 0;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if answer{1} ~= 0
            EEG.data = [];
            EEG.data = EEG.reconstructedEEG;
            EEG.reconstructedEEG = [];
            save(answer{1},'EEG');
            uiwait(msgbox('Data Saved.','DONE!','modal'));
        end
        
    end

    function quitLoop(source,event)

        close all;

    end

    function selectComponents(source,event)
    
        EEG.selectedComponents = get(source,'value');
        testString = [];
        for counter = 1:length(EEG.selectedComponents)
            newBit = [num2str(EEG.selectedComponents(counter)) ' '];
            testString = [testString newBit];
        end
        
        message1 = [testString];
        set(txt1, 'String', message1);
        
        redoMath;
        plotComponents;

    end

    function setICAChannel(source,event)
    
        EEG.icaChannel = source.Value;
      
        redoMath;
        plotComponents;

    end

    function setTimeWindow(source,event)
        
        prompt = {'Enter the start data point','Enter the end data point'};
        dlg_title = 'Set ICA Time Window';
        num_lines = 2;
        defaultans = {'1','10000'};
        answer{1} = 0;
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if answer{1} ~= 0
            EEG.icaT1 = str2num(answer{1});
            EEG.icaT2 = str2num(answer{2});
            EEG.icaTWidth = EEG.icaT2 - EEG.icaT1;
            redoMath;
            plotComponents;
        end

    end
    
end