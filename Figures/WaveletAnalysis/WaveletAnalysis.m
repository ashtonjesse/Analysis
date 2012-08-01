classdef WaveletAnalysis < SubFigure
    %WaveletAnalysis Summary
    %   This is the WaveletAnalysis class that wraps the
    %   WaveletAnalysisFig. It needs to be called from a parent figure 
    %   (e.g StartFigure) and the class wrapper
    %   for this parent passed as a input into the constructor. 
    
    %   This class assumes that the parent figure remains open while the
    %   WaveletAnalysisFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is done. 
    
    properties 

    end
    
    methods
        function oFigure = WaveletAnalysis(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'WaveletAnalysis',@WaveletAnalysis_OpeningFcn);
            
            %Set the callback functions to the controls
            %set(oFigure.oGuiHandle.oSignalSlider, 'callback', @(src, event) oSignalSlider_Callback(oFigure, src, event));

            
            aSliderTexts = [oFigure.oGuiHandle.oSliderText1,oFigure.oGuiHandle.oSliderText2];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels, 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[0.01  0.1]},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCWTMenu, 'callback', @(src, event) oCWTMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Turn zoom on for this figure
            zoom(oFigure.oGuiHandle.(oFigure.sFigureTag), 'on');                       
            
            %Plot the original and processed data of the first signal
            oFigure.PlotOriginal(1);
            
                       
            % --- Executes just before BaselineCorrection is made visible.
            function WaveletAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                
                
                %Set the output attribute
                handles.output = hObject;
                %Update the gui handles 
                guidata(hObject, handles);
            end
        end
    end
    
    
    methods (Access = protected)
         %% Protected methods inherited from superclass
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            nValue = GetPopUpSelectionDouble@BaseFigure(oFigure,sPopUpMenuTag);
        end
        
    end
    
    methods
        %% Ui control callbacks    
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
        
        % --------------------------------------------------------------------
        function oSlider_Callback(oFigure, src, event)
           % Plot the data associated with this channel
           oFigure.PlotOriginal(get(oFigure.oGuiHandle.oSlider,'Value'));
        end
        
               
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oCWTMenu_Callback(oFigure, src, event)

        end
        
    end
    
    %% Private methods
    methods (Access = private)
        function CreateSubPlot(oFigure)
             %Create the space for the subplot that will contain all the
             %graphs
             
             %Clear the subplot panel first
%              %Get the array of handles to the plot objects
%              aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
%              %Loop through list and delete
%              for i = 1:size(aPlotObjects,1)
%                  delete(aPlotObjects(i));
%              end
                 
%              %Find the bounds of the selected area
%              iMinChannel = min(oFigure.oMapElectrodesFigure.SelectedChannels);
%              iMaxChannel = max(oFigure.oMapElectrodesFigure.SelectedChannels);
%              %Convert into row and col indices
%              [iMinRow iMinCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMinChannel);
%              [iMaxRow iMaxCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMaxChannel);
%              %Divide up the space for the subplots
%              xDiv = 1/(iMaxRow-iMinRow+1); 
%              yDiv = 1/(iMaxCol-iMinCol+1);
%                          
%              %Loop through the selected channels
%              for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
%                  [iRow iCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(oFigure.oMapElectrodesFigure.SelectedChannels(i));
%                  %Normalise the row and columns to the minimum.
%                  iRow = iRow - iMinRow;
%                  iCol = iCol - iMinCol;
%                  %Create the position vector for the next plot
%                  aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
%                  %Create a subplot in the position specified
%                  oSignalPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals, 'Tag', ...
%                      sprintf('%d',oFigure.oMapElectrodesFigure.SelectedChannels(i)));
%              end
        end
         
        function PlotOriginal(oFigure, iChannel)
            %Clear the subplot panel first
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            %Loop through list and delete
            for i = 1:size(aPlotObjects,1)
                delete(aPlotObjects(i));
            end
            if ~isinteger(iChannel)
                %Round down to nearest integer if a double is supplied
                iChannel = round(iChannel(1));
            end
            sTitle = sprintf('Original Signal for Channel %d',iChannel);
            oAxes = axes('parent', oFigure.oGuiHandle.oAxesPanel);
            plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential,'k');
            axis(oAxes, 'auto');
            title(oAxes, sTitle);
        end
    end
        
end
