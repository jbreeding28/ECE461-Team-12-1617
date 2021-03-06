classdef NewDroneSystem1Channel
    %NEWDRONESYSTEM1CHANNEL Deprecated. This was used for testing purposes
    %in the early stages of the system. This code is only built to work
    %with 1 microphone so that it could be tested with the laptop's
    %microphone.
    
    properties
        % c holds constants
        c;
        % B holds the logistic regression model
        B;
        Boffset;
        Bslopes;
        % cutoff holds the cutoff accuracy for drones
        cutoff;
        % initialize detector with a placeholder so that it can be made
        % into an array of detector objects later on
        detectors = featureDetection();
        localiz;
        audioRecorder;
        F_AXIS;
        data;
    end
    
    methods
        function DS = NewDroneSystem1Channel(configSettings,kNNStuff)
            load('DataCollection_1_18_2017.mat');
            DS.c = configSettings.constants;
            % DS.localiz = localizer;
            DS.c.NUM_CHANNELS = 1;
            classes = ClassNumber;
            %features = double(DominantFrequencyValue);
            features = horzcat(double(DominantFrequency),double(DominantFrequencyValue));
            %    double(SpectrumCentroid));
            class0Endpoint = 1;
            for n = 1:length(classes)
                if(~eq(classes(n),classes(1)))
                    class0Endpoint = n - 1;
                    break;
                end
            end
            modelPercentage = 0.5;
            probabilityCutoff = 0.65;
            modelRuns = 10;

            class0Data = features(1:class0Endpoint,:);
            class1Data = features(class0Endpoint + 1:size(features,1),:);
            [B, dev, stats, accuracy] = ...
                generateSystemModel(class1Data, class0Data,...
                modelPercentage, probabilityCutoff, modelRuns)
            DS.B = B;
            DS.Boffset = B(1);
            DS.Bslopes = B(2:length(DS.B));
            DS.cutoff = probabilityCutoff;
            % initialize one detector for each channel
            for i = 1:DS.c.NUM_CHANNELS
                DS.detectors(i) = featureDetection(configSettings,kNNStuff);
            end
            
            %DS.audioRecorder = dsp.AudioRecorder('SamplesPerFrame', ...
            %    DS.c.FRAME_SIZE,'SampleRate',DS.c.Fs,'DeviceName', ...
            %    configSettings.audioDriver,'NumChannels', ...
            %    DS.c.NUM_CHANNELS);
            DS.audioRecorder = dsp.AudioRecorder('SamplesPerFrame', ...
                DS.c.FRAME_SIZE,'SampleRate',DS.c.Fs,'NumChannels', ...
                DS.c.NUM_CHANNELS);
            
            
            DS.F_AXIS = linspace(0,DS.c.Fs/2,DS.c.WINDOW_SIZE/2+1);
        end
        
        % consider trying to make an event called stop
        
        function start(DS)
            % setup the live plots
            decisions = {'1'; '2'; '3'; '4'};
            
            [hFig, hp, ha, hTextBox] = DS.figureSetup(decisions);
            
            numPointsFeatureSpace = 100;
            
            % features over time
            load('image_config.mat');
            % eventually, put the below line in the if statement below
            % DS.localiz.configImViewer(hIm);
            shutdown = 0;
            % MAIN LOOP
            while(~shutdown)
            try
                getFeatures = false(1);
                audioFrame = step(DS.audioRecorder);
                for i = 1:DS.c.NUM_CHANNELS
                    getFeatures = DS.detectors(1).step(audioFrame(:,1));
                    %Disp(char(getFeatures));
                    if getFeatures
                        features = DS.detectors(i).getFeatures();
                        relativeProb = exp(DS.Boffset + sum(DS.Bslopes.*features));
                        prob = relativeProb./(1+relativeProb);
                        %prob = 1;
                        pwr = DS.detectors(1).getPwrDB();
                        stringOutput = [num2str(prob) '    ' num2str(pwr)];
                        set(hTextBox(i),'String',stringOutput);
                    end
                end
%                 set(hp(1),'YData',DS.detectors(1).getEnergy(),'XData',...
%                     DS.detectors(i).getFlux());
%                 set(hp(2),'YData',DS.detectors(1).getPreviousSpectrum());
                
                %set(hp(1),'YData',f0s,'XData', fluxes,'ZData',zcrs);
                set(hp(2),'XData',DS.F_AXIS,'YData',...
                   DS.detectors(1).getPreviousSpectrum());
                drawnow;
                shutdown = getappdata(hFig,'shutdown');
                % if there is a complete setup, run the localizer
            catch ME
                % DS.localiz.historyToWorkspace();
                rethrow(ME);
            end
            
            end
            
            close(gcf);
        end
        
        function [decisionNums,fluxes,energies] = test(DS,singleAudioFrame)
            %TEST take a single audio frame and make a decision
            %   This function is meant to be called when there is a bunch
            %   of recorded data that the system is to be tested with.
            decisions = cell(DS.c.NUM_CHANNELS,1);
            decisionNums = zeros(DS.c.NUM_CHANNELS,1);
            fluxes = zeros(DS.c.NUM_CHANNELS,1);
            energies = zeros(DS.c.NUM_CHANNELS,1);
            for i = 1:DS.c.NUM_CHANNELS
                decisions(i) = {DS.detectors(i).step(singleAudioFrame...
                    (:,i))};
                decisionNumbers(i) = DS.classStringToNum(decisions(i));
                fluxes(i) = DS.detectors(i).getFlux();
                energies(i) = DS.detectors(i).getEnergy();
            end
            decisionNums = {decisionNumbers};
        end
        
%         function localizerStep(DS,Af1,Af2,Af3,Af4)
%             DS.localiz.direction()
%         end
  
        function localizerTest(DS,Af)
           % A = zeros(1,DS.c.NUM_CHANNELS);
%             for i = 1:DS.c.NUM_CHANNELS
%                 %DS.detectors(i) = Detector(configSettings);
%                 DS.detectors(i).step(Af(:,i));
%                 A(i) = DS.detectors(i).dronePresent(DS.detectors(i).previousSpectrum);
%             end
            A1 = sum(abs(Af(:,1)));
            A2 = sum(abs(Af(:,2)));
            A3 = sum(abs(Af(:,3)));
            A4 = sum(abs(Af(:,4)));

            mval = max([A1 A2 A3 A4]);
            A1 = A1/mval;
            A2 = A2/mval;
            A3 = A3/mval;
            A4 = A4/mval;
            DS.localiz.direction(A1,A2,A3,A4);
        end
        
        function [hFig, hp, ha, hTextBox] = figureSetup(DS, decisions)
        %FIGURESETUP a function used to setup a figure for testing purposes
            hFig = figure();
            setappdata(hFig,'shutdown',0);
            subplot(2,1,1);
            % 2D plot
%             hp(1) = plot(1,1,'O');
%             axis manual
%             ha(1) = gca;
%             set(ha(1),'YLimMode','manual')
% %             set(ha(1),'YLim',[0 1000],'YScale','log','XLim',[0 1], ...
% %                 'XScale','log')
%             % this is a line of great interest when calibrating with the
%             % hardware
%             set(ha(1),'YLim',[0 1000],'XLim',[0 0.02])
            
            % 3D plot
            hp(1) = plot3(1,1,1,'O');
            grid on
            ha(1) = gca;
            xlabel('Normalized spectral flux')
            ylabel('Fundemental frequency (Hz)')
            zlabel('Zero crossing rate')
            
            title('Feature space')
            
            subplot(2,1,2);
            hp(2) = plot(DS.F_AXIS,zeros(1,DS.c.WINDOW_SIZE/2+1));
            ha(2) = gca;
            set(ha(2),'YLimMode','manual')
            set(ha(2),'YLim',[0 1],'XLim',[0 20E3])
            set(ha(2),'Xscale','log')
            title('Current spectrum')
            
            % text boxes for displaying the output of each detector
            % (and information relevant to testing)
            for i = 1:DS.c.NUM_CHANNELS
                hTextBox(i) = uicontrol('style','text');
                set(hTextBox(i),'String',decisions(i));
                set(hTextBox(i),'Position',[0 30*i 300 25])
            end
            
            closeButton = uicontrol('Style','pushbutton','String','Close',...
                'Position',[500,5,50,20],'Callback', @closeWindow_Callback);
            
            function closeWindow_Callback(hObject, eventdata)
                setappdata(hObject.Parent, 'shutdown', 1);
            end
            
            % localizer image
            %figure
            %hIm = imshow(zeros(501,501,3));
        end
        
        function calibration(DS)
            % potentially something to implement in the future
        end
        
        function classNum = classStringToNum(DS,classString)
            if(strcmp('weak signal',classString))
                classNum = 1;
                return;
            elseif(strcmp('highly non-stationary signal',classString))
                classNum = 2;
                return;
            elseif(strcmp('non-drone oscillator signal',classString))
                classNum = 3;
                return;
            elseif(strcmp('drone signal',classString))
                classNum = 4;
                return;
            else
                warning('class string input does not match existing strings')
                classNum = -1;
            end
        end
        
    end
    
end