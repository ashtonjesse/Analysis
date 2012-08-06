classdef PotentialDAL < BaseDAL
    % PotentialDAL is the DAL class for entities that inherit from the
    % BasePotential class
    
    methods
        function oPotentialDAL = PotentialDAL()
            %%  Constructor
            oPotentialDAL = oPotentialDAL@BaseDAL();
        end
    end
    
    methods (Access = public)
        %% Public Inherited Methods
        function oData = GetEntityFromFile(oPotentialDAL,sFile)
            oData = GetEntityFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function oData = LoadFromFile(oPotentialDAL,sFile)
            oData = LoadFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function oEntity = CreateEntityFromFile(oPotentialDAL,sFile)
            oEntity = CreateEntityFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function SaveThisEntity(oPotentialDAL,oEntity,sPath)
            SaveThisEntity@BaseDAL(oPotentialDAL,oEntity,sPath);
        end
    end
    
    methods (Access = public)
        function oElectrodes = GetElectrodesFromConfigFile(oPotentialDAL,iNumberOfElectrodes,sFile)
            %Parses the file specified by sFile and populates an oElectrodes
            %struct.
            
            %Intitialise the struct
            oElectrodes = struct('Name', zeros(iNumberOfElectrodes,1));
            iElectrodeCount = 0;
            %Open the file and put into fid handle
            fid = fopen(sFile);
            %Get and discard the first 2 lines
            tline1 = fgets(fid);
            tline2 = fgets(fid);
            tline = fgets(fid);
            %Loop while there are new lines
            while ischar(tline)
                %Split the current line on the :
                [~,~,~,~,~,~,splitstring] = regexpi(tline,':');
                %Trim any white space off the split strings
                sField = strtrim(char(splitstring(1,1)));
                oValue  = strtrim(char(splitstring(1,2)));
                switch (sField)
                    case 'electrode'
                        %Increment the electrode count
                        iElectrodeCount = iElectrodeCount + 1;
                        %Check to see if the electrode count has reached
                        %the maximum
                        if iElectrodeCount > iNumberOfElectrodes 
                            break
                        end
                        %Initialise the electrode struct
                        
                        oElectrodes(iElectrodeCount).Name = oValue;
                        oElectrodes(iElectrodeCount).Accepted = 1; 
                        oElectrodes(iElectrodeCount).Activation = [];
                        oElectrodes(iElectrodeCount).Potential = [];
                        oElectrodes(iElectrodeCount).Processed = [];
                        oElectrodes(iElectrodeCount).Status = 'Potential';
                    case 'position'
                         %Split the oValue on the ,
                         [~,~,~,~,~,~,splitstring] = regexpi(oValue,',');
                         sXInfo = strtrim(char(splitstring(1,1)));
                         sYInfo  = strtrim(char(splitstring(1,2)));
                         %Split the sXInfo on the =
                         [~,~,~,~,~,~,splitstring] = regexpi(sXInfo,'=');
                         iXPos = str2double(strtrim(char(splitstring(1,2))));
                         %Split the sYInfo on the =
                         [~,~,~,~,~,~,splitstring] = regexpi(sYInfo,'=');
                         iYPos = str2double(strtrim(char(splitstring(1,2))));
                         oElectrodes(iElectrodeCount).Coords = [iXPos iYPos];
                    case 'channel'
                        oElectrodes(iElectrodeCount).Channel = str2double(oValue);
                end
                tline = fgets(fid);
            end
            %Trim extra zeros
            oElectrodes = oElectrodes(1:iElectrodeCount-1);
        end
        
        function GetDataFromSignalFile(oPotentialDAL,oUnemap,sFile)
            %Get the potential data from a signal file and puts into the
            %correct field of the Electrodes struct
            
            %Load the potential data from the txt file
            aFileContents = oPotentialDAL.LoadFromFile(sFile);
            %Get the potential data and initialise processed.data
            for i = 1:oUnemap.oExperiment.Unemap.NumberOfChannels
                oUnemap.Electrodes(i).Potential.Data = aFileContents(:,i+1);
                oUnemap.Electrodes(i).Processed.Data = NaN(size(aFileContents,1),1);
            end
            %Get the Timeseries data
            oUnemap.TimeSeries = [1:1:size(aFileContents,1)]*(1/oUnemap.oExperiment.Unemap.ADConversion.SamplingRate);
        end
    end
end

