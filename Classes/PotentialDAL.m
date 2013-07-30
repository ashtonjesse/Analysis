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
        function oElectrodes = GetElectrodesFromConfigFile(oPotentialDAL,iNumberOfElectrodes,sFile,iSpecificElectrode)
            %Parses the file specified by sFile and populates an oElectrodes
            %struct.
            %If you want a number of electrodes then specify
            %iNumberOfElectrodes > 0 and iSpecificElectrode = 0
            %If you want just a specific electrode then specify
            %iSpecificElectrode > 0
                      
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
                        if iSpecificElectrode > 0
                            %Check to see if the electrode count has reached
                            %the specific electrode
                            if iElectrodeCount == iSpecificElectrode
                                %Initialise the electrode struct
                                oElectrodes.Name = oValue;
                                oElectrodes.Accepted = 1;
                                oElectrodes.Activation = [];
                                oElectrodes.Potential = [];
                                oElectrodes.Processed = [];
                                oElectrodes.Status = 'Potential';
                                break
                            end
                        else
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
                        end
                    case 'position'
                        if iSpecificElectrode == 0
                            %Split the oValue on the ,
                            [~,~,~,~,~,~,splitstring] = regexpi(oValue,',');
                            sXInfo = strtrim(char(splitstring(1,1)));
                            sYInfo  = strtrim(char(splitstring(1,2)));
                            %Split the sXInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sXInfo,'=');
                            dXPos = str2double(strtrim(char(splitstring(1,2))));
                            %Split the sYInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sYInfo,'=');
                            dYPos = str2double(strtrim(char(splitstring(1,2))));
                            %Get the appropriate position for this
                            %electrode in terms of a row and column index
                            oElectrodes(iElectrodeCount).Coords = [dXPos ; dYPos];
                        end
                    case 'location'
                        if iSpecificElectrode == 0
                            %Split the oValue on the ,
                            [~,~,~,~,~,~,splitstring] = regexpi(oValue,',');
                            sXInfo = strtrim(char(splitstring(1,1)));
                            sYInfo  = strtrim(char(splitstring(1,2)));
                            %Split the sXInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sXInfo,'=');
                            iXLoc = str2double(strtrim(char(splitstring(1,2))));
                            %Split the sYInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sYInfo,'=');
                            iYLoc = str2double(strtrim(char(splitstring(1,2))));
                            oElectrodes(iElectrodeCount).Location = [iYLoc ; iXLoc];
                        end
                    case 'channel'
                        if iSpecificElectrode == 0
                            oElectrodes(iElectrodeCount).Channel = str2double(oValue);
                        end
                end
                tline = fgets(fid);
            end
            if iSpecificElectrode == 0
                %Trim extra zeros
                oElectrodes = oElectrodes(1:iElectrodeCount-1);
            end
            fclose(fid);
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
        
        function GetElectrodeFromSignalFile(oPotentialDAL, oUnemap, iElectrodeNumber, sFile)
            %Get the potential data for a given channel from the input
            %signal (txt) file.
            
             %Load the potential data from the txt file
            aFileContents = oPotentialDAL.LoadFromFile(sFile);
            %Get the potential data and initialise processed.data
            oUnemap.Electrodes.Potential.Data = aFileContents(:,iElectrodeNumber+1);
            oUnemap.Electrodes.Processed.Data = NaN(size(aFileContents,1),1);
            %Get the Timeseries data
            oUnemap.TimeSeries = [1:1:size(aFileContents,1)]*(1/oUnemap.oExperiment.Unemap.ADConversion.SamplingRate);
        end
    end
end

